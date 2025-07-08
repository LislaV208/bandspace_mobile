import 'user.dart';

/// Model żądania aktualizacji profilu
class UpdateProfileRequest {
  final String? name;

  const UpdateProfileRequest({
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

/// Model odpowiedzi na aktualizację profilu
class UpdateProfileResponse {
  final bool success;
  final String message;
  final User user;

  const UpdateProfileResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

/// Model odpowiedzi na usunięcie profilu
class DeleteProfileResponse {
  final bool success;
  final String message;

  const DeleteProfileResponse({
    required this.success,
    required this.message,
  });

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}