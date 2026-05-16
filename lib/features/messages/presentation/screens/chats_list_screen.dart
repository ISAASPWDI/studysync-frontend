// lib/features/messages/presentation/screens/chats_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  // In a real app, chats would come from a dedicated endpoint or WebSocket.
  // For now we show a placeholder that matches the UI design.
  final List<ChatModel> _chats = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(AppColors.textSecondary)),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(AppColors.primaryBlue)))
          : _chats.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: const Color(AppColors.chipBlue),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 48, color: Color(AppColors.primaryBlue)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin conversaciones aún',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando tengas un match podrás\nempezar a chatear',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 15),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => context.go('/discover'),
            icon: const Icon(Icons.explore),
            label: const Text('Descubrir compañeros'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
      itemBuilder: (_, i) => _ChatTile(chat: _chats[i]),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final user = chat.otherUser;
    final msg = chat.lastMessage;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(AppColors.primaryBlue),
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  )
                : null,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(AppColors.textPrimary)),
            ),
          ),
          if (msg != null)
            Text(
              timeago.format(msg.createdAt, locale: 'es'),
              style: const TextStyle(color: Color(AppColors.textHint), fontSize: 12),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              msg?.content ?? 'Inicia la conversación',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.unreadCount > 0 ? const Color(AppColors.textPrimary) : const Color(AppColors.textSecondary),
                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () => context.push(
        '/chat/${chat.id}',
        extra: {'name': user.name, 'avatar': user.avatarUrl},
      ),
    );
  }
}
