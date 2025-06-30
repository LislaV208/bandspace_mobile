import 'package:equatable/equatable.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Stan zarządzania zmianą hasła
class ChangePasswordState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool showCurrentPassword;
  final bool showNewPassword;
  final bool showConfirmPassword;

  const ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.showCurrentPassword = false,
    this.showNewPassword = false,
    this.showConfirmPassword = false,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  ChangePasswordState copyWith({
    bool? isLoading,
    Value<String?>? errorMessage,
    Value<String?>? successMessage,
    bool? showCurrentPassword,
    bool? showNewPassword,
    bool? showConfirmPassword,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage.value : this.errorMessage,
      successMessage: successMessage != null ? successMessage.value : this.successMessage,
      showCurrentPassword: showCurrentPassword ?? this.showCurrentPassword,
      showNewPassword: showNewPassword ?? this.showNewPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        showCurrentPassword,
        showNewPassword,
        showConfirmPassword,
      ];
}