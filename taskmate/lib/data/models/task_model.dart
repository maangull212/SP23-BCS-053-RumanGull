enum RepeatType { none, daily, weekly }

class TaskCategories {
  static const all = 'all';
  static const none = 'none';
  static const work = 'work';
  static const home = 'home';
  static const personal = 'personal';
  static const study = 'study';
  static const shopping = 'shopping';
  static const health = 'health';
  static const finance = 'finance';
  static const other = 'other';
  static const ordered = <String>[
    all,
    none,
    work,
    home,
    personal,
    study,
    shopping,
    health,
    finance,
    other
  ];
}

class Task {
  final int? id;
  final String title;
  final String description;
  final int? dueDate; // epoch millis
  final bool isCompleted;
  final RepeatType repeatType;
  final List<int> repeatDays; // weekdays (1=Mon ... 7=Sun)
  final int? notifyAt;
  final int createdAt;
  final int updatedAt;
  final String category;
  final int? userId; // NEW: owner user id (local auth)

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.repeatType,
    required this.repeatDays,
    required this.notifyAt,
    required this.createdAt,
    required this.updatedAt,
    this.category = TaskCategories.none,
    this.userId,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? dueDate,
    bool? isCompleted,
    RepeatType? repeatType,
    List<int>? repeatDays,
    int? notifyAt,
    int? createdAt,
    int? updatedAt,
    String? category,
    int? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      notifyAt: notifyAt ?? this.notifyAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'is_completed': isCompleted ? 1 : 0,
      'repeat_type': repeatType.name,
      'repeat_days': repeatDays.join(','),
      'notify_at': notifyAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category,
      'user_id': userId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    final repeatTypeStr = (map['repeat_type'] as String?) ?? 'none';
    final repeatType = RepeatType.values.firstWhere(
      (e) => e.name == repeatTypeStr,
      orElse: () => RepeatType.none,
    );
    final repeatDaysStr = (map['repeat_days'] as String?) ?? '';
    final repeatDays = repeatDaysStr.isEmpty
        ? <int>[]
        : repeatDaysStr
            .split(',')
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toList();
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDate: map['due_date'] as int?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      repeatType: repeatType,
      repeatDays: repeatDays,
      notifyAt: map['notify_at'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      category:
          (map['category'] as String?)?.toLowerCase() ?? TaskCategories.none,
      userId: map['user_id'] as int?,
    );
  }
}
