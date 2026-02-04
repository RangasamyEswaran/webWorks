import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../constants/storage_keys.dart';

enum SocketConnectionState { connected, disconnected, connecting, error }

class SocketClient {
  late IO.Socket _socket;
  final FlutterSecureStorage _secureStorage;
  final _connectionStateController =
      StreamController<SocketConnectionState>.broadcast();

  SocketConnectionState _currentState = SocketConnectionState.disconnected;

  SocketClient(this._secureStorage);

  Stream<SocketConnectionState> get connectionState =>
      _connectionStateController.stream;
  SocketConnectionState get currentState => _currentState;
  bool get isConnected => _currentState == SocketConnectionState.connected;

  Future<void> connect() async {
    if (_currentState == SocketConnectionState.connected ||
        _currentState == SocketConnectionState.connecting) {
      return;
    }

    _updateState(SocketConnectionState.connecting);

    try {
      final token = await _secureStorage.read(key: StorageKeys.authToken);

      _socket = IO.io(
        ApiConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(3000)
            .setReconnectionAttempts(5)
            .setAuth({'token': token})
            .build(),
      );

      _setupSocketListeners();
      _socket.connect();
    } catch (e) {
      print('Socket connection error: $e');
      _updateState(SocketConnectionState.error);
    }
  }

  void _setupSocketListeners() {
    _socket.onConnect((_) {
      print('Socket connected');
      _updateState(SocketConnectionState.connected);
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
      _updateState(SocketConnectionState.disconnected);
    });

    _socket.onConnectError((error) {
      print('Socket connection error: $error');
      _updateState(SocketConnectionState.error);
    });

    _socket.onError((error) {
      print('Socket error: $error');
      _updateState(SocketConnectionState.error);
    });
  }

  void _updateState(SocketConnectionState newState) {
    _currentState = newState;
    _connectionStateController.add(newState);
  }

  void disconnect() {
    if (_currentState != SocketConnectionState.disconnected) {
      _socket.disconnect();
      _updateState(SocketConnectionState.disconnected);
    }
  }

  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket.emit(event, data);
    } else {
      print('Cannot emit event: Socket not connected');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    _socket.off(event, handler);
  }

  void joinRoom(String room) {
    emit('join_room', {'room': room});
  }

  void leaveRoom(String room) {
    emit('leave_room', {'room': room});
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
  }
}
