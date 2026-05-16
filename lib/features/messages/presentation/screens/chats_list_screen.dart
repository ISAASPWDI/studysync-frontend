// lib/features/messages/presentation/screens/chats_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/websocket_service.dart';

// Modelo interno que une MatchModel + chatId resuelto
class _ChatEntry {
  final String chatId;
  final MatchModel match;
  String? lastMessageContent;
  DateTime? lastMessageTime;
  int unreadCount;

  _ChatEntry({
    required this.chatId,
    required this.match,
    this.lastMessageContent,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen>
    with WidgetsBindingObserver {
  final ApiService _api = ApiService();
  final WebSocketService _ws = WebSocketService();

  List<_ChatEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _initWs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Recarga cuando vuelve a primer plano (ej: regresa del chat)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  // ── WS: escucha mensajes nuevos para actualizar el preview ────────────────
  void _initWs() {
    _ws.connect().then((_) {
      _ws.onMessage = (msg) {
        if (!mounted) return;
        setState(() {
          final entry = _entries.firstWhere(
                (e) => e.chatId == msg.chatId,
            orElse: () => _ChatEntry(chatId: '', match: _entries.first.match),
          );
          if (entry.chatId.isEmpty) return;
          entry.lastMessageContent = msg.content;
          entry.lastMessageTime = msg.createdAt;
          entry.unreadCount++;
          // Mover al tope
          _entries.remove(entry);
          _entries.insert(0, entry);
        });
      };
    });
  }

  // ── Carga confirmed matches → resuelve chatId de cada uno ─────────────────
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await _api.getConfirmedMatches();

      // Para cada match confirmado, crear/obtener su chat
      final entries = <_ChatEntry>[];
      for (final match in matches) {
        try {
          final chatId = await _api.createChat(match.matchId);
          if (chatId.isEmpty) continue;

          // Obtener último mensaje y unreadCount
          final msgs = await _api.getMessages(chatId, limit: 1);
          final unread = await _api.getUnreadCount(chatId);

          entries.add(_ChatEntry(
            chatId: chatId,
            match: match,
            lastMessageContent: msgs.isNotEmpty ? msgs.last.content : null,
            lastMessageTime: msgs.isNotEmpty ? msgs.last.createdAt : null,
            unreadCount: unread,
          ));
        } catch (_) {
          // Si falla un chat individual, lo saltamos sin romper la lista
        }
      }

      // Ordenar por último mensaje (más reciente primero)
      entries.sort((a, b) {
        final ta = a.lastMessageTime ?? a.match.createdAt;
        final tb = b.lastMessageTime ?? b.match.createdAt;
        return tb.compareTo(ta);
      });

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openChat(_ChatEntry entry) {
    final user = entry.match.otherUser;
    // Resetear unread localmente al entrar
    setState(() => entry.unreadCount = 0);
    context.push('/chat/${entry.chatId}', extra: {
      'name': user.name,
      'avatar': user.avatarUrl,
      'career': user.subject,
      'university': user.university,
      'isOnline': user.isOnline,
      'bio': user.bio,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Color(AppColors.textPrimary),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(AppColors.textSecondary)),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(
              color: Color(AppColors.primaryBlue)))
          : _error != null
          ? _buildError()
          : _entries.isEmpty
          ? _buildEmpty()
          : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: Color(AppColors.textHint)),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(AppColors.textSecondary), fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(AppColors.chipBlue),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 48, color: Color(AppColors.primaryBlue)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin conversaciones aún',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando tengas un match aceptado\npodrás empezar a chatear',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(AppColors.textSecondary), fontSize: 15),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => context.go('/discover'),
            icon: const Icon(Icons.explore),
            label: const Text('Descubrir compañeros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: const Color(AppColors.primaryBlue),
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _entries.length,
        separatorBuilder: (_, __) =>
        const Divider(height: 1, indent: 80),
        itemBuilder: (_, i) => _ChatTile(
          entry: _entries[i],
          onTap: () => _openChat(_entries[i]),
        ),
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────
class _ChatTile extends StatelessWidget {
  final _ChatEntry entry;
  final VoidCallback onTap;

  const _ChatTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = entry.match.otherUser;
    final hasUnread = entry.unreadCount > 0;
    final timeLabel = entry.lastMessageTime != null
        ? timeago.format(entry.lastMessageTime!, locale: 'es')
        : timeago.format(entry.match.createdAt, locale: 'es');

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(AppColors.primaryBlue),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
              user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            )
                : null,
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight:
                hasUnread ? FontWeight.w700 : FontWeight.w600,
                fontSize: 16,
                color: const Color(AppColors.textPrimary),
              ),
            ),
          ),
          Text(
            timeLabel,
            style: TextStyle(
              color: hasUnread
                  ? const Color(AppColors.primaryBlue)
                  : const Color(AppColors.textHint),
              fontSize: 12,
              fontWeight:
              hasUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              entry.lastMessageContent ?? '¡Di hola! 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread
                    ? const Color(AppColors.textPrimary)
                    : const Color(AppColors.textSecondary),
                fontWeight:
                hasUnread ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${entry.unreadCount}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}