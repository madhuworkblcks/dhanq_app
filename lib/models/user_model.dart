class UserModel {
  final String? id;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.phoneNumber,
    this.name,
    this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      email: json['email'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, name: $name, email: $email, createdAt: $createdAt)';
  }
} 