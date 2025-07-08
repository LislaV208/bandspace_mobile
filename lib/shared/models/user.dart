/// Model danych użytkownika
class User {
  final int id;
  final String email;
  final String? name;

  const User({required this.id, required this.email, this.name});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'] ?? 0, email: map['email'] ?? '', name: map['name']);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] ?? 0, email: json['email'] ?? '', name: json['name']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name};
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email && other.name == name;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name);
  }
}
