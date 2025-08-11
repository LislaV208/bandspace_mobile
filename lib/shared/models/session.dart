import 'package:bandspace_mobile/shared/models/user.dart';

class Session {
  final String accessToken;
  final User user;
  final String? refreshToken;

  Session({required this.accessToken, required this.refreshToken, required this.user});

  factory Session.fromMap(Map<String, dynamic> json) {
    return Session(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'] ?? '',
      user: User.fromMap(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken, 'user': user.toMap()};
  }

}