class ApiConfig {
  static String get baseUrl => 'https://api.example.com/api/v1';
  static String get socketUrl => 'https://api.example.com/api/v1';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String events = '/events';
  static String eventDetails(String id) => '/events/$id';
  static String registerEvent(String id) => '/events/$id/register';
  static String unregisterEvent(String id) => '/events/$id/unregister';

  static String chatHistory(String eventId) => '/events/$eventId/chat/history';
  static String sendMessage(String eventId) => '/events/$eventId/chat/send';

  static const String registerFcmToken = '/notifications/register';
}
