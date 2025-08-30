import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';

class Track extends Equatable {
  final int id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? createdBy;

  const Track({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      createdBy: json['createdBy'] != null
          ? User.fromMap(json['createdBy'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdAt,
    updatedAt,
    createdBy,
  ];
}
