import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/theme/app_colors.dart';
import 'package:bandspace_mobile/shared/utils/formatters.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionListItem extends StatelessWidget {
  final Version version;
  final VoidCallback onTap;
  final int versionNumber;
  final bool isLatest;

  const TrackVersionListItem({
    super.key,
    required this.version,
    required this.onTap,
    required this.versionNumber,
    required this.isLatest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Numer wersji
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLatest ? AppColors.primary : AppColors.textHint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$versionNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Główne informacje
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Wersja $versionNumber',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isLatest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'AKTUALNA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Nazwa pliku
                    if (version.file?.filename != null)
                      Text(
                        version.file!.filename,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // Kto dodał i kiedy
                    Row(
                      children: [
                        if (version.uploader != null) ...[
                          Text(
                            'Dodane przez ${version.uploader!.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                        Text(
                          Formatters.formatRelativeTime(version.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ikona odtwarzania
              Icon(
                LucideIcons.play,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
