// lib/features/matches/presentation/screens/matches_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final ApiService _api = ApiService();

  List<MatchModel> _received = [];  // pending/received  → alguien te dio like
  List<MatchModel> _sent     = [];  // pending/sent      → tú diste like
  List<MatchModel> _accepted = [];  // confirmed         → match mutuo

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.getPendingReceivedMatches(),
        _api.getSentMatches(),
        _api.getConfirmedMatches(),
      ]);
      if (!mounted) return;
      setState(() {
        _received = results[0];
        _sent     = results[1];
        _accepted = results[2];
        _loading  = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryBlue),
        title: const Text('Matches',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadMatches,
          )
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Recibidos (${_received.length})'),
            Tab(text: 'Enviados (${_sent.length})'),
            Tab(text: 'Aceptados (${_accepted.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(
              color: Color(AppColors.primaryBlue)))
          : _error != null
          ? _buildError()
          : TabBarView(
        controller: _tabCtrl,
        children: [
          _MatchList(
            matches: _received,
            emptyMsg: 'Nadie te ha dado like aún',
            onChat: _openChat,
          ),
          _MatchList(
            matches: _sent,
            emptyMsg: 'No has dado like a nadie aún',
            onChat: _openChat,
          ),
          _MatchList(
            matches: _accepted,
            emptyMsg: 'Aún no tienes matches aceptados',
            onChat: _openChat,
          ),
        ],
      ),
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
              onPressed: _loadMatches,
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

// _openChat en _MatchesScreenState:
  Future<void> _openChat(MatchModel match) async {
    try {
      final chatId = await _api.createChat(match.matchId);
      if (!mounted) return;
      context.push(
        '/chat/$chatId',
        extra: {
          'name':     match.otherUser.name,
          'avatar':   match.otherUser.avatarUrl,
          'career':   match.otherUser.subject,     // subject = carrera/skill
          'isOnline': match.otherUser.isOnline,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el chat')),
      );
    }
  }
}

// ── Lista ────────────────────────────────────────────────────────────────────
class _MatchList extends StatelessWidget {
  final List<MatchModel> matches;
  final String emptyMsg;
  final Function(MatchModel) onChat;

  const _MatchList(
      {required this.matches,
        required this.emptyMsg,
        required this.onChat});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                size: 60, color: Color(AppColors.textHint)),
            const SizedBox(height: 12),
            Text(emptyMsg,
                style: const TextStyle(
                    color: Color(AppColors.textSecondary), fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(AppColors.primaryBlue),
      onRefresh: () async => onChat, // pull-to-refresh dispara recarga
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) =>
            _MatchCard(match: matches[i], onChat: () => onChat(matches[i])),
      ),
    );
  }
}

// ── Tarjeta ──────────────────────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onChat;

  const _MatchCard({required this.match, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final user = match.otherUser; // ahora es MatchUser
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(AppColors.primaryBlue),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))
                  : null,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 2),
                  // Universidad
                  if (user.university != null)
                    Row(
                      children: [
                        const Icon(Icons.school_rounded,
                            size: 12, color: Color(AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.university!,
                            style: const TextStyle(
                                color: Color(AppColors.textSecondary),
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  // Skill principal
                  if (user.subject != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.code_rounded,
                              size: 12, color: Color(AppColors.textSecondary)),
                          const SizedBox(width: 4),
                          Text(
                            user.subject!,
                            style: const TextStyle(
                                color: Color(AppColors.textSecondary),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  // Bio
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.bio!,
                        style: const TextStyle(
                            color: Color(AppColors.textHint),
                            fontSize: 12,
                            height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Status + online badge
                  Row(
                    children: [
                      _StatusBadge(status: match.status),
                      if (user.isOnline) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  size: 7, color: Colors.green.shade500),
                              const SizedBox(width: 4),
                              Text('En línea',
                                  style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Botón chat solo si aceptado
            if (match.status == 'accepted')
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline,
                    color: Color(AppColors.primaryBlue)),
                onPressed: onChat,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'accepted':
        bg = const Color(AppColors.chipGreen);
        fg = const Color(AppColors.chipGreenText);
        label = '✓ Aceptado';
        break;
      case 'pending':
        bg = const Color(0xFFFFF8ED);
        fg = Colors.orange.shade700;
        label = '⏳ Pendiente';
        break;
      default:
        bg = const Color(AppColors.chipBlue);
        fg = const Color(AppColors.chipBlueText);
        label = 'Enviado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}