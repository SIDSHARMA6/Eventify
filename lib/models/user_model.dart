class UserModel {
  final String id;
  final String email;
  final String role; // 'creator' or 'admin'

  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      role: map['role'],
    );
  }
}
