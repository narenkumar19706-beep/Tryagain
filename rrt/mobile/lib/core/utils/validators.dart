class Validators {
  static bool isNonEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static bool isValidEmail(String? value) {
    if (!isNonEmpty(value)) {
      return false;
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(value!.trim());
  }

  static bool isValidPhone(String? value) {
    if (!isNonEmpty(value)) {
      return false;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10;
  }
}
