// models/user_model.dart
class UserModel {
  final String fullName;
  final String email;
  final String password; // Plain text for v1 (no hashing)

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'],
      email: json['email'],
      password: json['password'],
    );
  }
}