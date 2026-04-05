import 'package:intl/intl.dart';

class DateFormatter {
  static String display(DateTime d) => DateFormat('d MMM y').format(d);
  static String dayMonth(DateTime d) => DateFormat('d MMM').format(d);
  static String monthYear(DateTime d) => DateFormat('MMMM y').format(d);
  static String weekday(DateTime d) => DateFormat('EEE').format(d);

  static bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static bool isYesterday(DateTime d) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  static String relative(DateTime d) {
    if (isToday(d)) return 'Today';
    if (isYesterday(d)) return 'Yesterday';
    return display(d);
  }
}
