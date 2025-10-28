import 'package:intl/intl.dart';

/// to maintain consistency and avoid code duplication.
class Formatters {
  // Private constructor to prevent instantiation
  Formatters._();

  /// Formats duration from milliseconds to MM:SS format.
  ///
  /// Returns '--:--' if [durationMs] is null.
  ///
  /// Example:
  /// - formatDuration(125000) returns "02:05"
  /// - formatDuration(null) returns "--:--"
  static String formatDurationFromMs(int? durationMs) {
    if (durationMs == null) return '--:--';
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats Duration object to MM:SS format.
  ///
  /// Example:
  /// - formatDurationFromDuration(Duration(minutes: 2, seconds: 5)) returns "02:05"
  /// - formatDurationFromDuration(Duration(seconds: 45)) returns "00:45"
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats file size from bytes to human-readable format.
  ///
  /// Returns '--' if [bytes] is null.
  ///
  /// Example:
  /// - formatFileSize(1024) returns "1.0KB"
  /// - formatFileSize(1048576) returns "1.0MB"
  /// - formatFileSize(null) returns "--"
  static String formatFileSize(int? bytes) {
    if (bytes == null) return '--';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Formats relative time from DateTime to human-readable format in Polish.
  ///
  /// Returns 'niedawno' if [dateTime] is null.
  ///
  /// Example:
  /// - formatRelativeTime(DateTime.now().subtract(Duration(days: 2))) returns "2 dni temu"
  /// - formatRelativeTime(DateTime.now().subtract(Duration(hours: 1))) returns "1h temu"
  /// - formatRelativeTime(null) returns "niedawno"
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'niedawno';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1
          ? 'rok'
          : years < 5
          ? 'lata'
          : 'lat'} temu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1
          ? 'miesiąc'
          : months < 5
          ? 'miesiące'
          : 'miesięcy'} temu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dzień' : 'dni'} temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m temu';
    } else {
      return 'przed chwilą';
    }
  }

  /// Formats DateTime to short date and time format.
  ///
  /// Example:
  /// - formatDateTime(DateTime(2024, 09, 24, 14, 30)) returns "24.09.2024, 14:30"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(dateTime);
  }

  /// Formats DateTime to short date format only.
  ///
  /// Example:
  /// - formatDate(DateTime(2024, 09, 24)) returns "24.09.2024"
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  /// Formats DateTime to time format only.
  ///
  /// Example:
  /// - formatTime(DateTime(2024, 09, 24, 14, 30)) returns "14:30"
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
