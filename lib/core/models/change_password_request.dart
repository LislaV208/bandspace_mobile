/// Model żądania zmiany hasła
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

/// Model odpowiedzi na zmianę hasła
class ChangePasswordResponse {
  final bool success;
  final String message;

  const ChangePasswordResponse({
    required this.success,
    required this.message,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}