class User {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final int createdAt;
  final int updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    int? createdAt,
    int? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email.toLowerCase(),
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: (map['email'] as String).toLowerCase(),
      passwordHash: map['password_hash'] as String,
      passwordSalt: map['password_salt'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }
}
