import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoIcons
import 'package:flutter/services.dart'; // HapticFeedback (vibration) ke liye
import 'package:intl/intl.dart'; // DateFormat ke liye
import 'dart:math'; // Random number ke liye

// --- 1. Data Models & Enums ---

// Naya Enum: Game ka state manage karne ke liye
enum GameState { setup, playing, finished }

// Naya Model: Player ka data store karne ke liye
class Player {
  final String id;
  String name;
  int score;

  Player({required this.id, required this.name, this.score = 0});
}

// Modified Model: History mein player ka naam add kiya
class RollHistory {
  final String id;
  final String playerName; // Naya: Kis player ne roll kiya
  final String details; // e.g., "2D6 + 1D20 + 5"
  final int total;
  final DateTime timestamp;

  RollHistory({
    required this.id,
    required this.playerName,
    required this.details,
    required this.total,
    required this.timestamp,
  });
}

// Dice ki types (e.g., 6-sided, 20-sided)
enum DieType { D4, D6, D8, D10, D12, D20 }

// Enum ke liye helper extension
extension DieTypeExtension on DieType {
  int get maxVal {
    switch (this) {
      case DieType.D4:
        return 4;
      case DieType.D6:
        return 6;
      case DieType.D8:
        return 8;
      case DieType.D10:
        return 10;
      case DieType.D12:
        return 12;
      case DieType.D20:
        return 20;
    }
  }

  String get name {
    return this.toString().split('.').last;
  }
}

// Screen pe har individual die ka object
class Die {
  final String id;
  final DieType type;
  int value;

  Die({required this.type, required this.value}) : id = Uuid().v4();
}

// Modified Model: Game ke hisab se stats
class RollStats {
  final double averageRoll;
  final int highestRoll;
  final int totalRolls;

  RollStats({
    this.averageRoll = 0,
    this.highestRoll = 0,
    this.totalRolls = 0,
  });
}

// Uuid class (halki si) taake unique IDs bana sakein
class Uuid {
  final Random _random = Random();
  String v4() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAllMapped(
      RegExp('[xy]'),
      (match) {
        final int r = (_random.nextDouble() * 16).floor();
        final int v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
        return v.toRadixString(16);
      },
    );
  }
}

// --- 2. App Start & Theme ---

void main() {
  runApp(DiceRollerApp());
}

class DiceRollerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heavy Dice Roller',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFF1A212A),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF4CAF50), // Green
          secondary: Color(0xFFCDDC39), // Lime
          surface: Color(0xFF2C3A47), // Darker card background
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Color(0xFF2C3A47),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: DiceRollerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- 3. Main App Page (Stateful Widget) ---

class DiceRollerPage extends StatefulWidget {
  @override
  _DiceRollerPageState createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final Uuid _uuid = Uuid();

  // --- State Variables ---

  // Game Logic State
  GameState _gameState = GameState.setup; // Shuru mein setup screen
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  String? _winnerId;
  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _targetScoreController =
      TextEditingController(text: "100");

  // Dice Rolling State
  List<Die> _diceList = [];
  List<RollHistory> _historyList = [];
  int _modifier = 0;
  DieType _selectedDieType = DieType.D6;
  int _lastTotal = 0;
  RollStats _stats = RollStats();

  // Animation
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _diceList = [
      Die(type: DieType.D6, value: 1),
      Die(type: DieType.D6, value: 6),
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _playerNameController.dispose();
    _targetScoreController.dispose();
    super.dispose();
  }

  // --- 4. Core Logic Functions ---

  // --- Game State Logic ---
  void _addPlayer() {
    final String name = _playerNameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _players.add(Player(id: _uuid.v4(), name: name));
        _playerNameController.clear();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _removePlayer(String id) {
    setState(() {
      _players.removeWhere((p) => p.id == id);
    });
    HapticFeedback.lightImpact();
  }

  void _startGame() {
    if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least 2 players to start the game!'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    setState(() {
      _gameState = GameState.playing;
    });
    HapticFeedback.mediumImpact();
  }

  void _resetGame() {
    setState(() {
      _gameState = GameState.setup;
      _players.clear();
      _historyList.clear();
      _stats = RollStats();
      _lastTotal = 0;
      _winnerId = null;
      _currentPlayerIndex = 0;
    });
    HapticFeedback.heavyImpact();
  }

  // --- Dice Roll Logic (Modified for Players) ---
  void _rollDice() {
    if (_diceList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one die to roll!'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    _animationController.forward(from: 0.0);

    int currentTotal = 0;
    String rollDetails = "";
    Map<DieType, int> dieCounts = {};

    for (var die in _diceList) {
      setState(() {
        die.value = _random.nextInt(die.type.maxVal) + 1;
        currentTotal += die.value;
      });
      dieCounts[die.type] = (dieCounts[die.type] ?? 0) + 1;
    }

    rollDetails = dieCounts.entries
        .map((entry) => "${entry.value}${entry.key.name}")
        .join(' + ');

    if (_modifier != 0) {
      currentTotal += _modifier;
      rollDetails += (_modifier > 0 ? ' + $_modifier' : ' - ${-_modifier}');
    }

    // Naya Logic: Player ka score update karna
    final Player currentPlayer = _players[_currentPlayerIndex];
    currentPlayer.score += currentTotal;

    final historyEntry = RollHistory(
      id: _uuid.v4(),
      playerName: currentPlayer.name, // Player ka naam log karna
      details: rollDetails,
      total: currentTotal,
      timestamp: DateTime.now(),
    );

    // Winner check karna
    final int targetScore = int.tryParse(_targetScoreController.text) ?? 100;
    bool winnerFound = false;
    if (currentPlayer.score >= targetScore) {
      winnerFound = true;
      _winnerId = currentPlayer.id;
    }

    setState(() {
      _lastTotal = currentTotal;
      _historyList.insert(0, historyEntry);
      _stats = _calculateStats();

      if (winnerFound) {
        _gameState = GameState.finished; // Game khatam!
      } else {
        // Agle player ki baari
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      }
    });
  }

  // --- Other Logic ---
  RollStats _calculateStats() {
    if (_historyList.isEmpty) return RollStats();

    double totalSum = _historyList.fold(0, (prev, roll) => prev + roll.total);
    double average = totalSum / _historyList.length;

    int highest =
        _historyList.map((r) => r.total).reduce((a, b) => a > b ? a : b);

    return RollStats(
      averageRoll: average,
      highestRoll: highest,
      totalRolls: _historyList.length,
    );
  }

  void _addDie() {
    setState(() {
      _diceList
          .add(Die(type: _selectedDieType, value: _selectedDieType.maxVal));
    });
    HapticFeedback.lightImpact();
  }

  void _removeDie(String id) {
    setState(() {
      _diceList.removeWhere((die) => die.id == id);
    });
    HapticFeedback.lightImpact();
  }

  void _updateModifier(int change) {
    setState(() {
      _modifier += change;
    });
    HapticFeedback.selectionClick();
  }

  // --- 5. Build Method (Main UI Router) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-player Dice Game'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // Reset button (hamesha available)
        actions: [
          if (_gameState != GameState.setup)
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Reset Game',
              onPressed: _resetGame,
            ),
        ],
      ),
      // Game state ke hisab se body change karna
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _buildCurrentStateScreen(),
      ),
    );
  }

  // Helper function to choose screen based on state
  Widget _buildCurrentStateScreen() {
    switch (_gameState) {
      case GameState.setup:
        return _buildSetupScreen();
      case GameState.playing:
        return _buildGameScreen();
      case GameState.finished:
        return _buildWinnerScreen();
    }
  }

  // --- 6. Custom UI Widgets (By Screen) ---

  // --- SCREEN 1: SETUP ---
  Widget _buildSetupScreen() {
    return SingleChildScrollView(
      key: ValueKey('setup'),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Game Setup',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // Target Score
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Target Score:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _targetScoreController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Add Player
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Add Players (Min 2)', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _playerNameController,
                          decoration: InputDecoration(
                            labelText: 'Player Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                      SizedBox(width: 12),
                      FilledButton(
                        onPressed: _addPlayer,
                        child: Text('Add'),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Player List
          ..._players.map((player) {
            return Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: ListTile(
                leading: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(player.name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade300),
                  onPressed: () => _removePlayer(player.id),
                ),
              ),
            );
          }),
          SizedBox(height: 32),

          // Start Game Button
          FilledButton.icon(
            onPressed: _startGame,
            icon: Icon(CupertinoIcons.game_controller_solid, size: 28),
            label: Text(
              'START GAME',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _players.length < 2
                  ? Colors.grey.shade700
                  : Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- SCREEN 2: PLAYING ---
  Widget _buildGameScreen() {
    final Player currentPlayer = _players[_currentPlayerIndex];
    return SingleChildScrollView(
      key: ValueKey('playing'),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Naya: Scoreboard
          _buildScoreboard(),
          SizedBox(height: 16),

          // Section 1: Total Result
          _buildTotalResultCard(),
          SizedBox(height: 16),

          // Section 2: Statistics
          _buildStatsGrid(),
          SizedBox(height: 20),

          // Section 3: Dice on Screen
          _buildDiceGrid(),
          SizedBox(height: 20),

          // Section 4: Controls (Dice add karna, etc. - yeh ab game setup ka hissa hai)
          // Hum isko game ke dauran bhi allow kar sakte hain
          _buildControlsCard(),
          SizedBox(height: 24),

          // Section 5: Roll Button (Modified)
          FilledButton.icon(
            onPressed: _rollDice,
            icon: Icon(CupertinoIcons.cube_fill, size: 28),
            label: Text(
              "ROLL FOR ${currentPlayer.name.toUpperCase()}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
          ),
          SizedBox(height: 24),

          // Section 6: History
          _buildHistorySection(),
        ],
      ),
    );
  }

  // --- SCREEN 3: FINISHED ---
  Widget _buildWinnerScreen() {
    final Player? winner = _winnerId == null
        ? null
        : _players.firstWhere((p) => p.id == _winnerId);
    return Center(
      key: ValueKey('finished'),
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WINNER!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              Icon(Icons.emoji_events,
                  size: 80, color: Theme.of(context).colorScheme.secondary),
              SizedBox(height: 16),
              Text(
                winner?.name ?? 'Unknown',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'with ${winner?.score ?? 0} points!',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _resetGame,
                icon: Icon(Icons.refresh),
                label: Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 7. Reusable UI Widgets (Game Screen) ---

  // Naya Widget: Scoreboard
  Widget _buildScoreboard() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'SCOREBOARD (Target: ${_targetScoreController.text})',
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                final bool isCurrent = index == _currentPlayerIndex;
                return Container(
                  width: 120,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        player.score.toString(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalResultCard() {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'LAST ROLL TOTAL',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$_lastTotal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GAME STATISTICS',
          style: TextStyle(
              color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            StatCard(
              title: 'Avg Roll',
              value: _stats.averageRoll.toStringAsFixed(1),
            ),
            StatCard(
              title: 'Total Turns',
              value: _stats.totalRolls.toString(),
            ),
            StatCard(
              title: 'Highest Roll',
              value: _stats.highestRoll.toString(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiceGrid() {
    if (_diceList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No dice on the table.\nAdd some dice from the controls below!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final angle = sin(_shakeAnimation.value * pi * 5) *
            (0.15 * (1 - _shakeAnimation.value));
        return Transform.rotate(
          angle: angle,
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: _diceList
                .map((die) => DieWidget(die: die, onRemove: _removeDie))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Dice & Modifier Setup (For ALL Players)',
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DieType>(
                    value: _selectedDieType,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: InputDecoration(
                      labelText: 'Select Die Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: DieType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDieType = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                FilledButton(
                  onPressed: _addDie,
                  child: Text('Add Die'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Modifier:',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton.filled(
                  icon: Icon(Icons.remove),
                  onPressed: () => _updateModifier(-1),
                ),
                Text(
                  '${_modifier >= 0 ? '+' : ''}$_modifier',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _modifier == 0
                          ? Colors.white
                          : (_modifier > 0
                              ? Colors.greenAccent
                              : Colors.redAccent)),
                ),
                IconButton.filled(
                  icon: Icon(Icons.add),
                  onPressed: () => _updateModifier(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GAME LOG',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        _historyList.isEmpty
            ? Center(
                child: Text(
                  'Your game log will appear here.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  final history = _historyList[index];
                  return HistoryTile(history: history);
                },
              ),
      ],
    );
  }
}

// --- 8. Custom Widgets (Small, Reusable) ---

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title.toUpperCase(),
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class DieWidget extends StatelessWidget {
  final Die die;
  final Function(String) onRemove;

  const DieWidget({Key? key, required this.die, required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                die.value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Text(
              die.type.name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: Icon(Icons.cancel, color: Colors.red.shade400, size: 20),
              onPressed: () => onRemove(die.id),
            ),
          ),
        ],
      ),
    );
  }
}

// Modified History Tile to show player name
class HistoryTile extends StatelessWidget {
  final RollHistory history;
  const HistoryTile({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
          child: Text(
            history.total.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        title: Text(
          "${history.playerName} rolled ${history.total}", // Naya title
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        subtitle: Text(
          history.details, // Details ab subtitle hain
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          // Time ko trailing mein daal diya
          DateFormat('hh:mm a').format(history.timestamp),
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}
