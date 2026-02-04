class SocketConfig {
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String error = 'error';
  static const String connectError = 'connect_error';
  static const String connectTimeout = 'connect_timeout';

  static const String eventStatusUpdate = 'event_status_update';
  static const String eventUpdate = 'event_update';

  static const String joinEventChat = 'join_event_chat';
  static const String leaveEventChat = 'leave_event_chat';
  static const String newMessage = 'new_message';
  static const String messageDelivered = 'message_delivered';
  static const String messageRead = 'message_read';
  static const String userTyping = 'user_typing';

  static String eventRoom(String eventId) => 'event_$eventId';
  static String chatRoom(String eventId) => 'chat_$eventId';
}
