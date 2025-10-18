import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? name;
  final DateTime? lastLoginAt;
  final List<String>? authProviders;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.lastLoginAt,
    required this.authProviders,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt']).toLocal(),
      authProviders: json['authProviders'] == null
          ? null
          : List<String>.from(json['authProviders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'authProviders': authProviders,
    };
  }

  factory User.fromMap(Map<String, dynamic> json) => User.fromJson(json);

  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [id, email, name, lastLoginAt, authProviders];
}
