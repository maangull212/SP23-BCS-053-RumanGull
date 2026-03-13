class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String bloodGroup;
  final String medicalHistory;
  final String diagnosis;
  final String medications;
  final String allergies;
  final String emergencyContact;
  final String? imagePath;
  final String documents; // JSON-encoded list of file paths
  final DateTime lastVisit;
  final DateTime createdAt;
  final bool isActive;

  const Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.email = '',
    this.address = '',
    required this.bloodGroup,
    this.medicalHistory = '',
    this.diagnosis = '',
    this.medications = '',
    this.allergies = '',
    this.emergencyContact = '',
    this.imagePath,
    this.documents = '[]',
    required this.lastVisit,
    required this.createdAt,
    this.isActive = true,
  });

  // ── Serialization ─────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'blood_group': bloodGroup,
      'medical_history': medicalHistory,
      'diagnosis': diagnosis,
      'medications': medications,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'image_path': imagePath,
      'documents': documents,
      'last_visit': lastVisit.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      bloodGroup: map['blood_group'] as String,
      medicalHistory: map['medical_history'] as String? ?? '',
      diagnosis: map['diagnosis'] as String? ?? '',
      medications: map['medications'] as String? ?? '',
      allergies: map['allergies'] as String? ?? '',
      emergencyContact: map['emergency_contact'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      documents: map['documents'] as String? ?? '[]',
      lastVisit: DateTime.parse(map['last_visit'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? email,
    String? address,
    String? bloodGroup,
    String? medicalHistory,
    String? diagnosis,
    String? medications,
    String? allergies,
    String? emergencyContact,
    String? imagePath,
    String? documents,
    DateTime? lastVisit,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      diagnosis: diagnosis ?? this.diagnosis,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      imagePath: imagePath ?? this.imagePath,
      documents: documents ?? this.documents,
      lastVisit: lastVisit ?? this.lastVisit,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get shortAddress =>
      address.isNotEmpty ? address.split(',').first : 'N/A';

  @override
  String toString() => 'Patient(id: $id, name: $name, age: $age)';
}
