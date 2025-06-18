class QueueParser {
  static int parseInt(dynamic value) {
    if (value == "Infinity" || value == "infinity") {
      return 999999; // Use a large number to represent infinity
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return value as int;
  }

  static bool parseBoolean(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  static String parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
