import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert'; // JSON encoding/decoding ke liye
import 'package:fl_chart/fl_chart.dart'; // Charts ke liye
import 'dart:math'; // Calculation ke liye

// UUID generator ka ek instance
const uuid = Uuid();

// --- 1. DATA MODELS (JSON Serialization ke sath) ---
// (In models mein koi change nahi)

class Subject {
  String id;
  String name;
  int creditHours;
  String grade;

  Subject({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.grade,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'creditHours': creditHours,
        'grade': grade,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        name: json['name'],
        creditHours: json['creditHours'],
        grade: json['grade'],
      );
}

class Semester {
  String id;
  String name;
  List<Subject> subjects;

  Semester({
    required this.id,
    required this.name,
    List<Subject>? subjects,
  }) : subjects = subjects ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
        id: json['id'],
        name: json['name'],
        subjects:
            (json['subjects'] as List).map((s) => Subject.fromJson(s)).toList(),
      );
}

// --- 2. PERSISTENCE SERVICE (Data Save/Load Logic) ---
// (Is service mein koi change nahi)

class StorageService {
  static const String _key = 'semesters';

  Future<void> saveSemesters(List<Semester> semesters) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> semestersJson =
        semesters.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, semestersJson);
  }

  Future<List<Semester>> loadSemesters() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? semestersJson = prefs.getStringList(_key);

    if (semestersJson == null) {
      return [];
    }
    try {
      return semestersJson
          .map((sJson) => Semester.fromJson(jsonDecode(sJson)))
          .toList();
    } catch (e) {
      print("Error loading data: $e");
      await prefs.remove(_key);
      return [];
    }
  }
}

// --- 3. ABSTRACTION (Calculation Logic) ---
// Saari calculation logic ko ek alag class mein move kar diya (Acha structure)

class CgpaCalculator {
  // Grade ko points mein convert karna
  static double getGradePoint(String grade) {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  // Sirf 1 semester ka GPA calculate karna
  static double calculateSemesterGPA(Semester semester) {
    if (semester.subjects.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (var subject in semester.subjects) {
      totalPoints += getGradePoint(subject.grade) * subject.creditHours;
      totalCredits += subject.creditHours;
    }
    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }

  // Saare semesters ka CGPA aur Total Credits calculate karna
  static Map<String, dynamic> calculateOverallStats(List<Semester> semesters) {
    double totalPoints = 0;
    int totalCredits = 0;

    for (var semester in semesters) {
      for (var subject in semester.subjects) {
        totalPoints += getGradePoint(subject.grade) * subject.creditHours;
        totalCredits += subject.creditHours;
      }
    }
    if (totalCredits == 0) return {'cgpa': 0.0, 'totalCredits': 0};

    return {
      'cgpa': totalPoints / totalCredits,
      'totalCredits': totalCredits,
    };
  }
}

// --- 4. APP START & THEME ---

void main() {
  runApp(CgpaCalculatorApp());
}

class CgpaCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator Pro',
      theme: ThemeData(
        // Ek professional, academic (university) theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, // Professional Blue/Indigo
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFF121212), // Darker background
        cardTheme: CardThemeData(
          elevation: 2,
          color: Color(0xFF1E1E1E), // Slightly lighter cards
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: AppShell(), // Home page ab 'AppShell' hai
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- 5. APP SHELL (Main Structure) ---
// Yeh root widget hai jo BottomNavigationBar aur state ko manage karta hai
// Bilkul React ke App.js ki tarah

class AppShell extends StatefulWidget {
  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final StorageService _storage = StorageService();
  int _selectedIndex = 0; // Current tab

  // --- LIFTED STATE ---
  // Saara data yahan root widget mein save hoga
  List<Semester> _semesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- Data Functions (State Management) ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _semesters = await _storage.loadSemesters();
    setState(() => _isLoading = false);
  }

  // Yeh function hum doosri screens ko pass karenge (React props ki tarah)
  Future<void> _updateAndSaveData(List<Semester> updatedSemesters) async {
    setState(() {
      _semesters = updatedSemesters;
    });
    await _storage.saveSemesters(_semesters);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screens ki list jo BottomNav se link hongi
    final List<Widget> _screens = [
      DashboardScreen(semesters: _semesters), // Tab 0
      TrendChartScreen(semesters: _semesters), // Tab 1
      SemesterListScreen(
          semesters: _semesters, onUpdate: _updateAndSaveData), // Tab 2
      GoalSetterScreen(semesters: _semesters), // Tab 3
    ];

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            // IndexedStack tabs ke state ko zinda rakhta hai
            : IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: 'Trend',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Semesters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_rounded),
            label: 'Goal Setter',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Taake 4 items sahi se fit hon
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// --- SCREEN 1: DASHBOARD (Heavy UI) ---

class DashboardScreen extends StatelessWidget {
  final List<Semester> semesters;
  const DashboardScreen({Key? key, required this.semesters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = CgpaCalculator.calculateOverallStats(semesters);
    final double cgpa = stats['cgpa'];
    final int totalCredits = stats['totalCredits'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 24),
          _buildCgpaGauge(context, cgpa), // "Heavy UI" Gauge Chart
          SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                context,
                'Total Credits',
                totalCredits.toString(),
                Icons.school_rounded,
                Colors.orangeAccent,
              ),
              SizedBox(width: 16),
              _buildStatCard(
                context,
                'Semesters',
                semesters.length.toString(),
                Icons.calendar_today_rounded,
                Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for stat cards
  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // "Heavy UI" Gauge Chart
  Widget _buildCgpaGauge(BuildContext context, double cgpa) {
    double percentage = (cgpa / 4.0);
    if (percentage.isNaN || percentage.isInfinite) percentage = 0;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center mein CGPA text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Overall CGPA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  Text(
                    cgpa.toStringAsFixed(3), // 3 decimal places
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              // Chart
              PieChart(
                PieChartData(
                  startDegreeOffset: -90, // Top se start ho
                  sectionsSpace: 0,
                  centerSpaceRadius: 100, // Beech ka hole
                  sections: [
                    // CGPA ki value
                    PieChartSectionData(
                      value: percentage,
                      color: Theme.of(context).colorScheme.primary,
                      radius: 20,
                      showTitle: false,
                    ),
                    // Baaqi 4.0 tak ka hissa
                    PieChartSectionData(
                      value: 1.0 - percentage,
                      color: Colors.grey.withOpacity(0.2),
                      radius: 20,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: TREND CHART (Heavy UI) ---

class TrendChartScreen extends StatelessWidget {
  final List<Semester> semesters;
  const TrendChartScreen({Key? key, required this.semesters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPA Trend'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              'Your GPA Trend Per Semester',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            _buildTrendChart(context),
          ],
        ),
      ),
    );
  }

  // "Heavy UI" Line Chart
  Widget _buildTrendChart(BuildContext context) {
    if (semesters.isEmpty) {
      return Center(child: Text('Add semesters to see your trend.'));
    }

    // Line chart ke liye data points (spots) banana
    final List<FlSpot> spots = [];
    for (int i = 0; i < semesters.length; i++) {
      final gpa = CgpaCalculator.calculateSemesterGPA(semesters[i]);
      spots.add(FlSpot(i.toDouble(), gpa));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                getDrawingVerticalLine: (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      // Semester 1, 2, 3...
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text('S${value.toInt() + 1}'),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1, // 0, 1, 2, 3, 4
                    getTitlesWidget: (value, meta) {
                      return Text(value.toStringAsFixed(1));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              minX: 0,
              maxX: (semesters.length - 1).toDouble(),
              minY: 0,
              maxY: 4.0, // Max GPA
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 3: SEMESTER LIST (Data Management) ---
// Yeh pichhli app ki main screen thi, ab yeh ek tab hai

class SemesterListScreen extends StatefulWidget {
  final List<Semester> semesters;
  // Yeh function AppShell se pass hoga (React props ki tarah)
  final Future<void> Function(List<Semester>) onUpdate;

  const SemesterListScreen(
      {Key? key, required this.semesters, required this.onUpdate})
      : super(key: key);

  @override
  _SemesterListScreenState createState() => _SemesterListScreenState();
}

class _SemesterListScreenState extends State<SemesterListScreen> {
  // Grade aur Credit Hours ke options (Dropdown ke liye)
  final List<String> _gradeOptions = [
    'A',
    'A-',
    'B+',
    'B',
    'B-',
    'C+',
    'C',
    'C-',
    'D+',
    'D',
    'F'
  ];
  final List<int> _creditOptions = [1, 2, 3, 4];

  // --- Data Functions (Jo AppShell ko update karti hain) ---

  Future<void> _addSemester(String name) async {
    final newSemester = Semester(id: uuid.v4(), name: name);
    widget.semesters.add(newSemester);
    await widget.onUpdate(widget.semesters);
    setState(() {}); // Local UI update karne ke liye
  }

  Future<void> _deleteSemester(String semesterId) async {
    widget.semesters.removeWhere((s) => s.id == semesterId);
    await widget.onUpdate(widget.semesters);
    setState(() {});
  }

  Future<void> _addSubject(Semester semester, Subject subject) async {
    semester.subjects.add(subject);
    await widget.onUpdate(widget.semesters);
    setState(() {});
  }

  Future<void> _deleteSubject(Semester semester, String subjectId) async {
    semester.subjects.removeWhere((s) => s.id == subjectId);
    await widget.onUpdate(widget.semesters);
    setState(() {});
  }

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Semesters'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: _showAddSemesterDialog,
            tooltip: 'Add Semester',
          ),
        ],
      ),
      body: widget.semesters.isEmpty
          ? Center(
              child: Text(
                'Tap the "+" button to add your first semester.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: widget.semesters.length,
              itemBuilder: (context, index) {
                final semester = widget.semesters[index];
                final double gpa =
                    CgpaCalculator.calculateSemesterGPA(semester);
                return _buildSemesterTile(semester, gpa);
              },
            ),
    );
  }

  // ExpansionTile widget
  Widget _buildSemesterTile(Semester semester, double gpa) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ExpansionTile(
        title: Text(
          semester.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'GPA: ${gpa.toStringAsFixed(2)}',
          style: TextStyle(
              color: gpa > 0 ? Colors.greenAccent : Colors.grey,
              fontWeight: FontWeight.w600),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _showDeleteSemesterDialog(semester.id),
        ),
        children: [
          _buildSubjectList(semester),
          TextButton.icon(
            onPressed: () => _showAddSubjectDialog(semester),
            icon: Icon(Icons.add),
            label: Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  // Subjects ki list (ExpansionTile ke andar)
  Widget _buildSubjectList(Semester semester) {
    return Column(
      children: [
        ...semester.subjects.map((subject) {
          return ListTile(
            title: Text(subject.name),
            subtitle: Text('Credits: ${subject.creditHours}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    subject.grade,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever,
                      size: 20, color: Colors.grey[600]),
                  onPressed: () => _deleteSubject(semester, subject.id),
                ),
              ],
            ),
          );
        }).toList(),
        if (semester.subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No subjects added yet.'),
          ),
      ],
    );
  }

  // --- Dialogs ---
  // (Yeh pichhli app se copy kiye gaye hain, lekin logic update kar diya hai)

  void _showAddSemesterDialog() {
    final _nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Semester'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Semester Name (e.g., "Fall 2023")'),
              validator: (value) =>
                  value!.trim().isEmpty ? 'Please enter a name' : null,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addSemester(_nameController.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSemesterDialog(String semesterId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete this semester and all its subjects?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              _deleteSemester(semesterId);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(Semester semester) {
    final _nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? _selectedGrade = _gradeOptions[0];
    int? _selectedCredits = _creditOptions[2]; // Default 3 credits

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Subject to ${semester.name}'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText:
                                'Subject Name (e.g., "Visual Programming")'),
                        validator: (value) => value!.trim().isEmpty
                            ? 'Please enter a name'
                            : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedCredits,
                        decoration: InputDecoration(labelText: 'Credit Hours'),
                        items: _creditOptions.map((credits) {
                          return DropdownMenuItem(
                              value: credits, child: Text('$credits Credits'));
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedCredits = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration:
                            InputDecoration(labelText: 'Grade Received'),
                        items: _gradeOptions.map((grade) {
                          return DropdownMenuItem(
                              value: grade, child: Text(grade));
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedGrade = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newSubject = Subject(
                        id: uuid.v4(),
                        name: _nameController.text.trim(),
                        creditHours: _selectedCredits!,
                        grade: _selectedGrade!,
                      );
                      _addSubject(semester, newSubject);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add Subject'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// --- SCREEN 4: GOAL SETTER (New Functionality) ---

class GoalSetterScreen extends StatefulWidget {
  final List<Semester> semesters;
  const GoalSetterScreen({Key? key, required this.semesters}) : super(key: key);

  @override
  _GoalSetterScreenState createState() => _GoalSetterScreenState();
}

class _GoalSetterScreenState extends State<GoalSetterScreen> {
  final _targetCgpaController = TextEditingController();
  final _remainingCreditsController = TextEditingController();

  double _requiredGpa = 0.0;
  bool _isCalculated = false;

  void _calculateGoal() {
    setState(() {
      _isCalculated = false;
      _requiredGpa = 0.0;
    });

    final double targetCgpa = double.tryParse(_targetCgpaController.text) ?? 0;
    final int remainingCredits =
        int.tryParse(_remainingCreditsController.text) ?? 0;

    if (targetCgpa <= 0 || targetCgpa > 4.0 || remainingCredits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter valid inputs (CGPA <= 4.0).'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final stats = CgpaCalculator.calculateOverallStats(widget.semesters);
    final double currentCgpa = stats['cgpa'];
    final int currentCredits = stats['totalCredits'];

    // Formula: (TargetCGPA * TotalCredits) - (CurrentCGPA * CurrentCredits)
    //          ---------------------------------------------------------
    //                          RemainingCredits

    double currentPoints = currentCgpa * currentCredits;
    int totalTargetCredits = currentCredits + remainingCredits;
    double totalTargetPoints = targetCgpa * totalTargetCredits;

    double requiredPoints = totalTargetPoints - currentPoints;
    double requiredGpa = requiredPoints / remainingCredits;

    setState(() {
      _requiredGpa = requiredGpa;
      _isCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CGPA Goal Setter'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What CGPA do you want?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _targetCgpaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target CGPA (e.g., 3.5)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _remainingCreditsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Remaining Credit Hours (e.g., 60)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _calculateGoal,
              icon: Icon(Icons.calculate_rounded),
              label: Text('Calculate'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 32),

            // Result
            if (_isCalculated)
              Card(
                color: _requiredGpa > 4.0
                    ? Colors.red.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'You need to maintain a GPA of:',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _requiredGpa.toStringAsFixed(3),
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'in your remaining ${_remainingCreditsController.text} credits.',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (_requiredGpa > 4.0)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            '(This is mathematically not possible)',
                            style: TextStyle(color: Colors.red[100]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
