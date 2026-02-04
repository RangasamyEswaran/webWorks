class AppConstants {
  static const String appName = 'EventHub';
  static const String appVersion = '1.0.0';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  static const int pageSize = 20;
  static const int initialPage = 1;

  static const int socketReconnectionDelay = 3000;
  static const int socketReconnectionAttempts = 5;

  static const int cacheValidityDuration = 3600;

  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';
}
