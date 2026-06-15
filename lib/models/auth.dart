class User {
  const User({
    required this.id,
    required this.phone,
    required this.name,
  });

  final int id;
  final String phone;
  final String name;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phone: json['phone'] as String,
      name: json['name'] as String,
    );
  }
}

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.token,
  });

  final User user;
  final String token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
