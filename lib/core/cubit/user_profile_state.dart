import 'package:equatable/equatable.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Stan zarządzania profilem użytkownika
class UserProfileState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final User? user;
  final bool isEditing;

  const UserProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.user,
    this.isEditing = false,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  UserProfileState copyWith({
    bool? isLoading,
    Value<String?>? errorMessage,
    Value<String?>? successMessage,
    Value<User?>? user,
    bool? isEditing,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage.value : this.errorMessage,
      successMessage: successMessage != null ? successMessage.value : this.successMessage,
      user: user != null ? user.value : this.user,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        user,
        isEditing,
      ];
}