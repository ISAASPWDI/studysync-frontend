// lib/features/messages/presentation/screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../core/services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? otherUserCareer;
  final String? otherUserUniversity;
  final String? otherUserBio;
  final bool otherUserIsOnline;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserCareer,
    this.otherUserUniversity,
    this.otherUserBio,
    this.otherUserIsOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final WebSocketService _ws = WebSocketService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<MessageModel> _messages = [];
  bool _loading = true;
  bool _isTyping = false;
  Timer? _typingTimer;

  // IDs de mensajes enviados localmente, para deduplicar el echo del WS
  final Set<String> _pendingLocalIds = {};

  String get _myId => context.read<AuthProvider>().user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initWs();
  }

  @override
  void dispose() {
    _ws.leaveChat(widget.chatId);
    // Limpiar callbacks para no recibir eventos en otra pantalla
    _ws.onMessage = null;
    _ws.onTyping = null;
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await _api.getMessages(widget.chatId);
      setState(() {
        // La API devuelve del más viejo al más nuevo; los mostramos en ese orden
        _messages = msgs.reversed.toList();
        _loading = false;
      });
      _markRead();
      _scrollToBottom();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _initWs() {
    _ws.connect().then((_) {
      _ws.joinChat(widget.chatId);

      _ws.onMessage = (msg) {
        if (msg.chatId != widget.chatId) return;

        // Si el mensaje viene con un senderId que es el mío y tenía
        // un temp local pendiente, solo actualizamos el id real y
        // descartamos el duplicado en lugar de agregar uno nuevo.
        if (msg.senderId == _myId && _pendingLocalIds.isNotEmpty) {
          // El WS confirma nuestro mensaje: actualizamos el tempMsg
          setState(() {
            final idx = _messages.indexWhere(
                  (m) => _pendingLocalIds.contains(m.id),
            );
            if (idx != -1) {
              _pendingLocalIds.remove(_messages[idx].id);
              _messages[idx] = msg; // reemplaza temp por el real
            } else {
              // Por si acaso no encontramos el temp
              _messages.add(msg);
            }
          });
          _scrollToBottom();
          return;
        }

        // Mensaje del otro usuario: agregarlo normalmente
        setState(() => _messages.add(msg));
        _scrollToBottom();
        _markRead();
      };

      _ws.onTyping = (userId, isTyping) {
        if (userId != _myId) setState(() => _isTyping = isTyping);
      };
    });
  }

  void _markRead() {
    final unread = _messages
        .where((m) => m.senderId != _myId && !m.read)
        .map((m) => m.id)
        .toList();
    if (unread.isNotEmpty) {
      _api.markAsRead(widget.chatId, unread);
      _ws.markAsRead(widget.chatId, unread);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTyping() {
    _ws.sendTyping(widget.chatId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _ws.sendTyping(widget.chatId, false);
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    // ID temporal local único
    final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    _pendingLocalIds.add(tempId);

    final tempMsg = MessageModel(
      id: tempId,
      chatId: widget.chatId,
      senderId: _myId,
      content: text,
      createdAt: DateTime.now(),
      read: false,
    );

    setState(() => _messages.add(tempMsg));
    _scrollToBottom();

    // Emitir por WS; el servidor lo devolverá con id real
    _ws.sendMessage(widget.chatId, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryBlue),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _showUserInfo(context),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(child: _buildHeaderInfo()),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(AppColors.primaryBlue)))
                : _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMine = msg.senderId == _myId;
                final showTime = i == 0 ||
                    _messages[i]
                        .createdAt
                        .difference(_messages[i - 1].createdAt)
                        .inMinutes >
                        10;
                return Column(
                  children: [
                    if (showTime)
                      _buildDateDivider(msg.createdAt),
                    _MessageBubble(
                      message: msg,
                      isMine: isMine,
                      isPending:
                      _pendingLocalIds.contains(msg.id),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Toca el header → muestra info del otro usuario ───────────────────────
  void _showUserInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(AppColors.primaryBlue),
              backgroundImage: widget.otherUserAvatar != null
                  ? NetworkImage(widget.otherUserAvatar!)
                  : null,
              child: widget.otherUserAvatar == null
                  ? Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(widget.otherUserName,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary))),
            if (widget.otherUserCareer != null) ...[
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.code_rounded,
                    size: 14, color: Color(AppColors.textSecondary)),
                const SizedBox(width: 4),
                Text(widget.otherUserCareer!,
                    style: const TextStyle(
                        color: Color(AppColors.textSecondary),
                        fontSize: 14)),
              ]),
            ],
            if (widget.otherUserUniversity != null) ...[
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.school_rounded,
                    size: 14, color: Color(AppColors.textSecondary)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(widget.otherUserUniversity!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 14)),
                ),
              ]),
            ],
            if (widget.otherUserBio != null &&
                widget.otherUserBio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(widget.otherUserBio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 14)),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          backgroundImage: widget.otherUserAvatar != null
              ? NetworkImage(widget.otherUserAvatar!)
              : null,
          child: widget.otherUserAvatar == null
              ? Text(
            widget.otherUserName.isNotEmpty
                ? widget.otherUserName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(AppColors.primaryBlue),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
              : null,
        ),
        if (widget.otherUserIsOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(AppColors.primaryBlue), width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    final subtitle = _isTyping
        ? 'Escribiendo...'
        : widget.otherUserIsOnline
        ? 'En línea'
        : widget.otherUserCareer ?? widget.otherUserUniversity ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.otherUserName,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              color: _isTyping
                  ? Colors.white
                  : widget.otherUserIsOnline
                  ? Colors.greenAccent.shade100
                  : Colors.white60,
              fontSize: 12,
              fontWeight:
              _isTyping ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor:
            const Color(AppColors.primaryBlue).withOpacity(0.1),
            backgroundImage: widget.otherUserAvatar != null
                ? NetworkImage(widget.otherUserAvatar!)
                : null,
            child: widget.otherUserAvatar == null
                ? Text(
              widget.otherUserName.isNotEmpty
                  ? widget.otherUserName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Color(AppColors.primaryBlue),
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            )
                : null,
          ),
          const SizedBox(height: 14),
          Text(widget.otherUserName,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(AppColors.textPrimary))),
          if (widget.otherUserCareer != null) ...[
            const SizedBox(height: 4),
            Text(widget.otherUserCareer!,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(AppColors.textSecondary))),
          ],
          if (widget.otherUserUniversity != null) ...[
            const SizedBox(height: 2),
            Text(widget.otherUserUniversity!,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(AppColors.textHint))),
          ],
          const SizedBox(height: 10),
          Text(
            '¡Di hola a ${widget.otherUserName.split(' ').first}!',
            style: const TextStyle(
                fontSize: 15,
                color: Color(AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    final label = diff == 0
        ? 'Hoy'
        : diff == 1
        ? 'Ayer'
        : '${dt.day}/${dt.month}/${dt.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: const TextStyle(
                    color: Color(AppColors.textHint), fontSize: 12)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2))
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              onChanged: (_) => _onTyping(),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle:
                const TextStyle(color: Color(AppColors.textHint)),
                filled: true,
                fillColor: const Color(AppColors.surfaceGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(AppColors.primaryBlue),
                shape: BoxShape.circle,
              ),
              child:
              const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bubble ────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool isPending; // mensaje local aún no confirmado por el servidor

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine
              ? const Color(AppColors.primaryBlue)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMine
                    ? Colors.white
                    : const Color(AppColors.textPrimary),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine
                        ? Colors.white60
                        : const Color(AppColors.textHint),
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  // Pending → reloj; enviado → done/done_all
                  Icon(
                    isPending
                        ? Icons.access_time
                        : message.read
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color: isPending
                        ? Colors.white38
                        : message.read
                        ? Colors.white
                        : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}