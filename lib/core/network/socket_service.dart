import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  bool get isConnected => _socket?.connected ?? false;

  void init(String url) {
    if (_socket != null) return;

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket Connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket Disconnected');
    });

    _socket!.onError((data) {
      print('Socket Error: $data');
    });
  }

  void connect() {
    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
