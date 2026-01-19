class Formatters {
  static String formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return value;
    }
    final area = digits.substring(0, 3);
    final middle = digits.substring(3, 6);
    final last = digits.substring(6, 10);
    return '($area) $middle-$last';
  }

  static String formatShortDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$month/$day/$year';
  }
}
