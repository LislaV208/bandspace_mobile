import 'package:parsable/parsable.dart';

class AuthenticationTokens extends Parsable {
  String get accessToken => get('accessToken');
  String get refreshToken => get('refreshToken');

  const AuthenticationTokens._({required super.data});

  factory AuthenticationTokens({
    required String accessToken,
    required String refreshToken,
  }) => AuthenticationTokens._(
    data: {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    },
  );

  factory AuthenticationTokens.fromMap(Map<String, dynamic> map) => AuthenticationTokens._(data: map);
}
