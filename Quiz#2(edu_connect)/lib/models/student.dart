class Student {
  int? id;
  String name;
  String email;
  int age;
  String? imagePath;
  String department;
  String createdAt;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    this.imagePath,
    required this.department,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'imagePath': imagePath,
      'department': department,
      'createdAt': createdAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      imagePath: map['imagePath'],
      department: map['department'],
      createdAt: map['createdAt'],
    );
  }

  Student copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    String? imagePath,
    String? department,
    String? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      imagePath: imagePath ?? this.imagePath,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
