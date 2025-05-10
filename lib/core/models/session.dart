import 'package:bandspace_mobile/core/models/user.dart';

/// Model danych sesji
class Session {
  final String accessToken;
  final String refreshToken;
  final User user;

  Session({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}
