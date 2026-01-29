class ApiConfig {
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Response Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverErrorMsg = 'Server error. Please try again later.';
  static const String unauthorizedError =
      'Session expired. Please login again.';
  static const String timeoutError = 'Request timeout. Please try again.';
}
