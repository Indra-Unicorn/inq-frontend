class QueueParser {
  static int parseInt(dynamic value) {
    if (value == null) {
      return 0; // Return 0 for null values
    }
    if (value == "Infinity" || value == "infinity") {
      return 999999; // Use a large number to represent infinity
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is int) {
      return value;
    }
    // Try to parse as string and then to int
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool parseBoolean(dynamic value) {
    if (value == null) return false;
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
