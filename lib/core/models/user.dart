/// Model danych użytkownika
class User {
  final String id;
  final String email;
  final Map<String, dynamic> userData;

  User({
    required this.id,
    required this.email,
    required this.userData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      userData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      ...userData,
    };
  }
}
