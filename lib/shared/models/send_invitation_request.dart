import 'package:equatable/equatable.dart';

class SendInvitationRequest extends Equatable {
  final String email;

  const SendInvitationRequest({
    required this.email,
  });

  factory SendInvitationRequest.fromJson(Map<String, dynamic> json) {
    return SendInvitationRequest(
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  List<Object?> get props => [email];
}