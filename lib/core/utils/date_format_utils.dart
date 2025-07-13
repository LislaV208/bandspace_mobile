class DateFormatUtils {
  /// Formatuje czas w formie względnym (np. "2h temu")
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
}
