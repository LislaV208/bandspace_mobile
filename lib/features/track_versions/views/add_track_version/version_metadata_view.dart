import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/audio_preview_player.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_state.dart';
import 'package:bandspace_mobile/features/track_versions/models/add_version_data.dart';
import 'package:bandspace_mobile/shared/widgets/bpm_control.dart';

class VersionMetadataView extends StatefulWidget {
  final AddTrackVersionState state;

  const VersionMetadataView({
    super.key,
    required this.state,
  });

  @override
  State<VersionMetadataView> createState() => _VersionMetadataViewState();
}

class _VersionMetadataViewState extends State<VersionMetadataView> {
  final _formKey = GlobalKey<FormState>();
  int? _bpm;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.state is AddTrackVersionFileSelected) {
      final state = widget.state as AddTrackVersionFileSelected;
      _bpm = state.metadata.bpm;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is! AddTrackVersionFileSelected) {
      return const Center(child: Text('Nie wybrano pliku'));
    }

    final selectedState = widget.state as AddTrackVersionFileSelected;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Preview Player
                AudioPreviewPlayer(audioFile: selectedState.file),

                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BpmControl(
                        initialBpm: _bpm,
                        showRemoveButton: true,
                        onBpmChanged: (bpm) {
                          setState(() {
                            _bpm = bpm;
                          });
                          final newMetadata = AddVersionData(bpm: bpm);
                          context.read<AddTrackVersionCubit>().updateMetadata(
                            newMetadata,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: _buildButtons(context),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AddTrackVersionCubit>().goBack();
              },
              icon: const Icon(LucideIcons.arrowLeft),
              label: const Text('Wstecz'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AddTrackVersionCubit>().proceedToUpload();
              },
              icon: const Icon(LucideIcons.upload, size: 20),
              label: Text(
                'Dodaj wersję',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
