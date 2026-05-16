// lib/core/services/websocket_service.dart
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';
import '../models/models.dart';
import 'storage_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  io.Socket? _socket;
  final StorageService _storage = StorageService();

  Function(MessageModel)? onMessage;
  Function(String userId, bool isTyping)? onTyping;
  Function(String userId, String status)? onUserStatus;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _storage.getToken();
    if (token == null) {
      debugPrint('❌ WS: No token available');
      return;
    }

    _socket = io.io(
      AppConstants.wsUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])       // fuerza WS, no polling
          .disableAutoConnect()
          .setAuth({'token': token})          // el gateway lee handshake.auth.token
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setTimeout(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        debugPrint('✅ WS conectado: ${_socket!.id}');
      })
      ..onDisconnect((reason) {
        debugPrint('🔴 WS desconectado: $reason');
      })
      ..onConnectError((err) {
        debugPrint('❌ WS error de conexión: $err');
      })
      ..onError((err) {
        debugPrint('❌ WS error: $err');
      })
    // Mensajes nuevos — el gateway emite 'newMessage'
      ..on('newMessage', (data) {
        debugPrint('📨 newMessage: $data');
        try {
          final map = _toMap(data);
          // el gateway envía { message: {...}, chatId: "..." }
          final msgMap = map['message'] as Map<String, dynamic>? ?? map;
          onMessage?.call(MessageModel.fromJson(msgMap));
        } catch (e) {
          debugPrint('❌ Error parseando newMessage: $e');
        }
      })
    // Typing — el gateway emite 'userTyping'
      ..on('userTyping', (data) {
        try {
          final map = _toMap(data);
          onTyping?.call(
            map['userId']?.toString() ?? '',
            map['isTyping'] as bool? ?? false,
          );
        } catch (_) {}
      })
    // Estado online/offline de contactos
      ..on('userStatusChange', (data) {
        try {
          final map = _toMap(data);
          onUserStatus?.call(
            map['userId']?.toString() ?? '',
            map['status']?.toString() ?? 'offline',
          );
        } catch (_) {}
      })
      ..on('messagesRead', (data) {
        debugPrint('✓✓ messagesRead: $data');
      })
      ..on('error', (data) {
        debugPrint('❌ WS server error: $data');
      });

    _socket!.connect();
  }

  // ── Emitters ────────────────────────────────────────────────────────────

  void sendMessage(String chatId, String content) {
    _emit('sendMessage', {
      'chatId': chatId,
      'content': content,
      'type': 'text',
    });
  }

  void sendTyping(String chatId, bool isTyping) {
    _emit('typing', {'chatId': chatId, 'isTyping': isTyping});
  }

  void markAsRead(String chatId, List<String> messageIds) {
    _emit('markAsRead', {'chatId': chatId, 'messageIds': messageIds});
  }

  void joinChat(String chatId) {
    _emit('joinChat', {'chatId': chatId});
  }

  void leaveChat(String chatId) {
    _emit('leaveChat', {'chatId': chatId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _emit(String event, Map<String, dynamic> data) {
    if (!isConnected) {
      debugPrint('⚠️ WS: intento de emit sin conexión ($event)');
      return;
    }
    _socket!.emit(event, data);
    debugPrint('📤 WS emit: $event → $data');
  }

  /// socket_io_client a veces entrega List en vez de Map
  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is List && data.isNotEmpty && data[0] is Map) {
      return Map<String, dynamic>.from(data[0] as Map);
    }
    return {};
  }
}