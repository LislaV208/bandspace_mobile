import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_create/file_picker_step.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_create/song_details_step.dart';

/// Ekran tworzenia nowego utworu z 2-stepowym flow
class CreateSongScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const CreateSongScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<CreateSongScreen> createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Dane z Step 1
  File? _selectedFile;
  String? _fileName;

  // Dane z Step 2
  String _songTitle = '';
  String _songDescription = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: [
                FilePickerStep(
                  onFileSelected: _onFileSelected,
                ),
                SongDetailsStep(
                  fileName: _fileName ?? '',
                  initialTitle: _songTitle,
                  initialDescription: _songDescription,
                  onDetailsChanged: _onDetailsChanged,
                  onCancel: _goToPreviousStep,
                  onCreate: _createSong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nowy utwór',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _currentStep == 0 ? 'Wybierz plik audio' : 'Uzupełnij szczegóły',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 1
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFileSelected(File file) {
    setState(() {
      _selectedFile = file;
      _fileName = path.basename(file.path);
      // Auto-wypełnij tytuł z nazwy pliku (bez rozszerzenia)
      _songTitle = path.basenameWithoutExtension(file.path);
    });

    _goToNextStep();
  }

  void _onDetailsChanged(String title, String description) {
    setState(() {
      _songTitle = title;
      _songDescription = description;
    });
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildUploadingScreen(double progress) {
    final progressPercentage = (progress * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.cloud_upload,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Przesyłanie utworu...',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _songTitle,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$progressPercentage%',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSong() async {
    // if (_selectedFile != null && _songTitle.isNotEmpty) {
    //   final dto = CreateSongWithFileDto(
    //     title: _songTitle,
    //     file: _selectedFile!,
    //     notes: _songDescription.isNotEmpty ? _songDescription : null,
    //   );

    //   final createdSong = await context
    //       .read<ProjectSongsCubit>()
    //       .createSongWithFile(dto);

    //   if (createdSong != null && mounted) {
    //     // Nawiguj do ekranu utworu
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => SongDetailScreen.fromSong(
    //           projectId: widget.projectId,
    //           song: createdSong,
    //         ),
    //       ),
    //     );
    //   } else if (mounted) {
    //     // Jeśli wystąpił błąd, pozostań na tym ekranie
    //     // Błąd zostanie pokazany przez BlocListener
    //   }
    // }
  }
}
