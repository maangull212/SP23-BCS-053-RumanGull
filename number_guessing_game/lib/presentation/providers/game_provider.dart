import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/game_result.dart';

enum Difficulty { easy, medium, hard }

enum GuessStatus { none, tooLow, tooHigh, correct }

class GameProvider extends ChangeNotifier {
  // ── Config ─────────────────────────────────────────────────────────────────
  static const _config = {
    Difficulty.easy: {'min': 1, 'max': 50, 'attempts': 10, 'label': 'Easy'},
    Difficulty.medium: {'min': 1, 'max': 100, 'attempts': 7, 'label': 'Medium'},
    Difficulty.hard: {'min': 1, 'max': 200, 'attempts': 5, 'label': 'Hard'},
  };

  // ── State ──────────────────────────────────────────────────────────────────
  Difficulty _difficulty = Difficulty.medium;
  int _targetNumber = 0;
  int _attemptsUsed = 0;
  int _maxAttempts = 7;
  int _rangeMin = 1;
  int _rangeMax = 100;
  GuessStatus _lastStatus = GuessStatus.none;
  int _lastGuess = 0;
  bool _gameOver = false;
  bool _won = false;
  int _score = 0;
  List<int> _guessHistory = [];
  List<GameResult> _results = [];
  Map<String, dynamic> _stats = {};

  // ── Getters ────────────────────────────────────────────────────────────────
  Difficulty get difficulty => _difficulty;
  int get targetNumber => _targetNumber;
  int get attemptsUsed => _attemptsUsed;
  int get attemptsLeft => _maxAttempts - _attemptsUsed;
  int get maxAttempts => _maxAttempts;
  int get rangeMin => _rangeMin;
  int get rangeMax => _rangeMax;
  GuessStatus get lastStatus => _lastStatus;
  int get lastGuess => _lastGuess;
  bool get gameOver => _gameOver;
  bool get won => _won;
  int get score => _score;
  List<int> get guessHistory => List.unmodifiable(_guessHistory);
  List<GameResult> get results => List.unmodifiable(_results);
  Map<String, dynamic> get stats => Map.unmodifiable(_stats);
  String get difficultyLabel =>
      (_config[_difficulty]!['label'] as String);

  // ── Game Logic ─────────────────────────────────────────────────────────────

  void setDifficulty(Difficulty d) {
    _difficulty = d;
    notifyListeners();
  }

  void startGame() {
    final cfg = _config[_difficulty]!;
    _rangeMin = cfg['min'] as int;
    _rangeMax = cfg['max'] as int;
    _maxAttempts = cfg['attempts'] as int;
    _targetNumber = _rangeMin + Random().nextInt(_rangeMax - _rangeMin + 1);
    _attemptsUsed = 0;
    _lastStatus = GuessStatus.none;
    _lastGuess = 0;
    _gameOver = false;
    _won = false;
    _score = 0;
    _guessHistory = [];
    notifyListeners();
  }

  /// Returns GuessStatus after evaluating the guess.
  Future<GuessStatus> submitGuess(int guess) async {
    if (_gameOver) return _lastStatus;

    _lastGuess = guess;
    _attemptsUsed++;
    _guessHistory.add(guess);

    if (guess == _targetNumber) {
      _lastStatus = GuessStatus.correct;
      _won = true;
      _gameOver = true;
      _score = _calculateScore();
      await _saveResult();
    } else if (guess < _targetNumber) {
      _lastStatus = GuessStatus.tooLow;
    } else {
      _lastStatus = GuessStatus.tooHigh;
    }

    if (!_gameOver && _attemptsUsed >= _maxAttempts) {
      _gameOver = true;
      _score = 0;
      await _saveResult();
    }

    notifyListeners();
    return _lastStatus;
  }

  int _calculateScore() {
    // More attempts left = higher score; difficulty multiplier applied
    final multiplier = {
      Difficulty.easy: 1,
      Difficulty.medium: 2,
      Difficulty.hard: 3,
    }[_difficulty]!;
    return (attemptsLeft + 1) * multiplier * 100;
  }

  Future<void> _saveResult() async {
    final result = GameResult(
      difficulty: difficultyLabel,
      targetNumber: _targetNumber,
      attempts: _attemptsUsed,
      maxAttempts: _maxAttempts,
      won: _won,
      score: _score,
      playedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.insertResult(result);
  }

  // ── History ────────────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    _results = await DatabaseHelper.instance.getAllResults();
    _stats = await DatabaseHelper.instance.getStats();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await DatabaseHelper.instance.clearAll();
    await loadHistory();
  }
}
