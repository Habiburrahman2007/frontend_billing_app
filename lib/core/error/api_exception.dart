class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.errors,
    this.statusCode,
  });

  /// Returns the first validation error for a given field, or null.
  String? fieldError(String field) {
    final fieldErrors = errors?[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
