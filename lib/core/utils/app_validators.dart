class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a price';
    }
    // Strip dot thousand-separators before parsing
    final cleaned = value.replaceAll('.', '');
    if (double.tryParse(cleaned) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(cleaned) < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }
}
