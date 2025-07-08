import 'package:equatable/equatable.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Enum reprezentujący różne kroki resetowania hasła
enum ResetPasswordStep { enterEmail, enterToken, completed }

/// Stan zarządzania resetowaniem hasła
class ResetPasswordState extends Equatable {
  final ResetPasswordStep step;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool showNewPassword;
  final bool showConfirmPassword;
  final String? resetToken; // Token do resetowania hasła (tylko w środowisku testowym)

  const ResetPasswordState({
    this.step = ResetPasswordStep.enterEmail,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.showNewPassword = false,
    this.showConfirmPassword = false,
    this.resetToken,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  ResetPasswordState copyWith({
    ResetPasswordStep? step,
    bool? isLoading,
    Value<String?>? errorMessage,
    Value<String?>? successMessage,
    bool? showNewPassword,
    bool? showConfirmPassword,
    Value<String?>? resetToken,
  }) {
    return ResetPasswordState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage.value : this.errorMessage,
      successMessage: successMessage != null ? successMessage.value : this.successMessage,
      showNewPassword: showNewPassword ?? this.showNewPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      resetToken: resetToken != null ? resetToken.value : this.resetToken,
    );
  }

  @override
  List<Object?> get props => [
        step,
        isLoading,
        errorMessage,
        successMessage,
        showNewPassword,
        showConfirmPassword,
        resetToken,
      ];
}