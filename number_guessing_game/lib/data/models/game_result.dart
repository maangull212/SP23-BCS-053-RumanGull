class GameResult {
  final int? id;
  final String difficulty;
  final int targetNumber;
  final int attempts;
  final int maxAttempts;
  final bool won;
  final int score;
  final DateTime playedAt;

  const GameResult({
    this.id,
    required this.difficulty,
    required this.targetNumber,
    required this.attempts,
    required this.maxAttempts,
    required this.won,
    required this.score,
    required this.playedAt,
  });

  /// Convert model → SQLite row
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'difficulty': difficulty,
        'target_number': targetNumber,
        'attempts': attempts,
        'max_attempts': maxAttempts,
        'won': won ? 1 : 0,
        'score': score,
        'played_at': playedAt.toIso8601String(),
      };

  /// Convert SQLite row → model
  factory GameResult.fromMap(Map<String, dynamic> map) => GameResult(
        id: map['id'] as int?,
        difficulty: map['difficulty'] as String,
        targetNumber: map['target_number'] as int,
        attempts: map['attempts'] as int,
        maxAttempts: map['max_attempts'] as int,
        won: (map['won'] as int) == 1,
        score: map['score'] as int,
        playedAt: DateTime.parse(map['played_at'] as String),
      );
}
