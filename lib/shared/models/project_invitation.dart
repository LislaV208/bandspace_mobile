import 'package:equatable/equatable.dart';
import 'user.dart';
import 'project.dart';

enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
}

class ProjectInvitation extends Equatable {
  final int id;
  final int? projectId;
  final int? invitedBy;
  final String email;
  final String? token;
  final InvitationStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Project? project;
  final User? invitedByUser;

  const ProjectInvitation({
    required this.id,
    this.projectId,
    this.invitedBy,
    required this.email,
    this.token,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.updatedAt,
    this.project,
    this.invitedByUser,
  });

  factory ProjectInvitation.fromJson(Map<String, dynamic> json) {
    return ProjectInvitation(
      id: json['id'] ?? 0,
      projectId: json['project_id'],
      invitedBy: json['invited_by'],
      email: json['email'] ?? '',
      token: json['token'],
      status: _statusFromString(json['status']),
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      project: json['project'] != null 
          ? Project.fromJson(json['project']) 
          : null,
      invitedByUser: json['invitedBy'] != null 
          ? User.fromJson(json['invitedBy']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'invited_by': invitedBy,
      'email': email,
      'token': token,
      'status': _statusToString(status),
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'project': project?.toJson(),
      'invitedBy': invitedByUser?.toJson(),
    };
  }

  static InvitationStatus _statusFromString(String? status) {
    switch (status) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'rejected':
        return InvitationStatus.rejected;
      case 'expired':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.pending;
    }
  }

  static String _statusToString(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return 'pending';
      case InvitationStatus.accepted:
        return 'accepted';
      case InvitationStatus.rejected:
        return 'rejected';
      case InvitationStatus.expired:
        return 'expired';
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;
  bool get canBeAccepted => isPending;

  ProjectInvitation copyWith({
    int? id,
    int? projectId,
    int? invitedBy,
    String? email,
    String? token,
    InvitationStatus? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Project? project,
    User? invitedByUser,
  }) {
    return ProjectInvitation(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      invitedBy: invitedBy ?? this.invitedBy,
      email: email ?? this.email,
      token: token ?? this.token,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      project: project ?? this.project,
      invitedByUser: invitedByUser ?? this.invitedByUser,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        invitedBy,
        email,
        token,
        status,
        expiresAt,
        createdAt,
        updatedAt,
        project,
        invitedByUser,
      ];
}