import 'package:flutter/material.dart';

import 'package:bandspace_mobile/shared/theme/app_colors.dart';
import 'package:bandspace_mobile/features/track_versions/views/add_track_version/add_track_version_view.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

class AddTrackVersionScreen extends StatefulWidget {
  final Track track;
  final int projectId;

  const AddTrackVersionScreen({
    super.key,
    required this.track,
    required this.projectId,
  });

  @override
  State<AddTrackVersionScreen> createState() => _AddTrackVersionScreenState();
}

class _AddTrackVersionScreenState extends State<AddTrackVersionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nowa wersja'),
            Text(
              widget.track.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: AddTrackVersionView(
        track: widget.track,
        projectId: widget.projectId,
        onUploadSuccess: (newVersion) {
          Navigator.pop(context, newVersion);
        },
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
