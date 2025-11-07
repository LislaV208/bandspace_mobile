/// Model żądania resetowania hasła
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

/// Model odpowiedzi na żądanie resetowania hasła
class ForgotPasswordResponse {
  final bool success;
  final String message;
  final String? resetToken; // Tylko w środowisku testowym

  const ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      resetToken: json['resetToken'],
    );
  }
}

/// Model żądania resetowania hasła z tokenem
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}

/// Model odpowiedzi na resetowanie hasła
class ResetPasswordResponse {
  final bool success;
  final String message;

  const ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
