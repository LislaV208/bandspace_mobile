import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class Track extends Equatable {
  final int id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Version? mainVersion;
  final User createdBy;

  const Track({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.mainVersion,
    required this.createdBy,
  });

  @override
  String toString() {
    return 'Track{id: $id, title: $title}';
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      mainVersion: json['mainVersion'] != null
          ? Version.fromJson(json['mainVersion'])
          : null,
      createdBy: User.fromJson(json['createdBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'mainVersion': mainVersion?.toJson(),
      'createdBy': createdBy.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdAt,
    updatedAt,
    mainVersion,
    createdBy,
  ];
}
