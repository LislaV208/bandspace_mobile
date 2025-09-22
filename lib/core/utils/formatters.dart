/// Utility class containing reusable formatting functions for the entire application.
///
/// This class provides consistent formatting for common data types like
/// duration, file size, dates, etc. Used across multiple models and widgets
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
  static String formatDuration(int? durationMs) {
    if (durationMs == null) return '--:--';
    final duration = Duration(milliseconds: durationMs);
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

  /// Formats relative time from DateTime to human-readable format.
  ///
  /// Example:
  /// - formatRelativeTime(DateTime.now().subtract(Duration(days: 2))) returns "2d temu"
  /// - formatRelativeTime(DateTime.now().subtract(Duration(hours: 1))) returns "1h temu"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m temu';
    } else {
      return 'Teraz';
    }
  }
}