// lib/features/auth/model/user.dart

class User {
  final int id;
  final String email;
  final String name;
  final String phoneNumber;
  final bool isDoctor;
  final String? clinicName;
  final String? clinicAddress;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.isDoctor,
    this.clinicName,
    this.clinicAddress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isDoctor: json['isDoctor'] as bool,
      clinicName: json['clinicName'] as String?,
      clinicAddress: json['clinicAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'isDoctor': isDoctor,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
    };
  }
}