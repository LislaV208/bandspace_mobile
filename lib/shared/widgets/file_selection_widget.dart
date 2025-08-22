import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

/// Uniwersalny komponent wyboru pliku audio - używany w NewSong i AddSongFile
class FileSelectionWidget extends StatelessWidget {
  final bool isSelecting;
  final VoidCallback onSelectFile;
  final VoidCallback? onSkipFile; // null = nie pokazuj przycisku pominięcia
  final String title;
  final String subtitle;
  final String buttonText;
  final bool showSupportedFormats;

  const FileSelectionWidget({
    super.key,
    required this.isSelecting,
    required this.onSelectFile,
    this.onSkipFile,
    this.title = 'Wybierz plik audio',
    this.subtitle = 'Dotknij aby wybrać plik z urządzenia', 
    this.buttonText = 'Przeglądaj pliki',
    this.showSupportedFormats = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(32, 32, 32, onSkipFile != null ? 16 : 32),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                width: 3,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    LucideIcons.fileAudio,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isSelecting ? null : onSelectFile,
                    icon: isSelecting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        : const Icon(LucideIcons.folderOpen, size: 20),
                    label: Text(
                      isSelecting ? '' : buttonText,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (onSkipFile != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isSelecting ? null : onSkipFile,
                    child: const Text('Pomiń plik audio'),
                  ),
                ],
              ],
            ),
          ),
          if (showSupportedFormats) ...[
            const SizedBox(height: 32),
            Column(
              children: [
                Text(
                  'Obsługiwane formaty:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MP3, WAV, M4A, FLAC, AAC',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}