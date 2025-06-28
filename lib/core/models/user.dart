/// Model danych użytkownika
class User {
  final int id;
  final String? email;
  final String? name;

  const User({required this.id, this.email, this.name});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'] ?? 0, email: map['email'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name};
  }
}
