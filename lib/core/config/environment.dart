class EnvironmentConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://nonlosable-snakier-clair.ngrok-free.dev/api',
  );

  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  static String get apiBaseUrl => '$baseUrl/$apiVersion';

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authRequestOtp = '/auth/request-otp';
  static const String authLogout = '/auth/logout';

  static const String edirList = '/edir';
  static const String edirNearby = '/edir/nearby';
  static const String edirSearch = '/edir/search';
  static const String edirDetails = '/edir/:id';
  static const String edirCreate = '/edir';
  static const String edirUpdate = '/edir/:id';

  static const String memberList = '/members';
  static const String memberDetails = '/members/:id';
  static const String memberApplications = '/members/applications';
  static const String memberApplicationReview =
      '/members/applications/:id/review';

  static const String contributionsList = '/contributions';
  static const String contributionsCreate = '/contributions';
  static const String contributionsStats = '/contributions/stats';

  static const String supportRequestsList = '/support-requests';
  static const String supportRequestsCreate = '/support-requests';
  static const String supportRequestsReview = '/support-requests/:id/review';

  static const String adminStats = '/admin/stats';
  static const String adminDashboard = '/admin/dashboard';
}
