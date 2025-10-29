import 'package:equatable/equatable.dart';

class AuthenticationTokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthenticationTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];

  factory AuthenticationTokens.fromMap(Map<String, dynamic> map) {
    return AuthenticationTokens(
      accessToken: map['accessToken'],
      refreshToken: map['refreshToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
