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

  List<MatchModel> _received = [];
  List<MatchModel> _sent = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Solo 2 tabs: Recibidos y Enviados
    // Los aceptados ya viven en la pantalla de Chats
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getPendingReceivedMatches(),
        _api.getSentMatches(),
      ]);
      if (!mounted) return;
      setState(() {
        _received = results[0];
        _sent = results[1];
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

  // Al aceptar: acepta el match, crea el chat y navega directo a él (solo esta vez)
  Future<void> _acceptMatch(MatchModel match) async {
    try {
      await _api.acceptMatch(match.matchId);
      final chatId = await _api.createChat(match.matchId);
      if (!mounted) return;

      if (chatId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Conectado con ${match.otherUser.name}!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _loadMatches();
        return;
      }

      // Navega al chat inmediatamente (primera vez)
      context.push('/chat/$chatId', extra: {
        'name': match.otherUser.name,
        'avatar': match.otherUser.avatarUrl,
        'career': match.otherUser.subject,
        'university': match.otherUser.university,
        'isOnline': match.otherUser.isOnline,
        'bio': match.otherUser.bio,
      });

      // Recarga la lista para quitar el match de "Recibidos"
      _loadMatches();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al aceptar')),
      );
    }
  }

  Future<void> _rejectMatch(MatchModel match) async {
    try {
      await _api.rejectMatch(match.matchId);
      if (!mounted) return;
      _loadMatches();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al rechazar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryBlue),
        title: const Text(
          'Matches',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadMatches,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Recibidos (${_received.length})'),
            Tab(text: 'Enviados (${_sent.length})'),
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
            onAccept: _acceptMatch,
            onReject: _rejectMatch,
          ),
          _MatchList(
            matches: _sent,
            emptyMsg: 'No has dado like a nadie aún',
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
                    color: Color(AppColors.textSecondary),
                    fontSize: 14)),
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
}

// ── Lista ─────────────────────────────────────────────────────────────────────
class _MatchList extends StatelessWidget {
  final List<MatchModel> matches;
  final String emptyMsg;
  final Function(MatchModel)? onAccept;
  final Function(MatchModel)? onReject;

  const _MatchList({
    required this.matches,
    required this.emptyMsg,
    this.onAccept,
    this.onReject,
  });

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
                    color: Color(AppColors.textSecondary),
                    fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(AppColors.primaryBlue),
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _MatchCard(
          match: matches[i],
          onAccept:
          onAccept != null ? () => onAccept!(matches[i]) : null,
          onReject:
          onReject != null ? () => onReject!(matches[i]) : null,
        ),
      ),
    );
  }
}

// ── Tarjeta ───────────────────────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _MatchCard({
    required this.match,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final user = match.otherUser;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
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
                          fontSize: 20))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(AppColors.textPrimary))),
                      if (user.university != null)
                        Row(children: [
                          const Icon(Icons.school_rounded,
                              size: 12,
                              color: Color(AppColors.textSecondary)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(user.university!,
                                style: const TextStyle(
                                    color:
                                    Color(AppColors.textSecondary),
                                    fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                      if (user.subject != null)
                        Row(children: [
                          const Icon(Icons.code_rounded,
                              size: 12,
                              color: Color(AppColors.textSecondary)),
                          const SizedBox(width: 4),
                          Text(user.subject!,
                              style: const TextStyle(
                                  color:
                                  Color(AppColors.textSecondary),
                                  fontSize: 12)),
                        ]),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(user.bio!,
                              style: const TextStyle(
                                  color: Color(AppColors.textHint),
                                  fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                      const SizedBox(height: 6),
                      _StatusBadge(status: match.status),
                    ],
                  ),
                ),
              ],
            ),
            // Botones solo para recibidos pendientes
            if (match.status == 'pending' && onAccept != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.red, size: 18),
                      label: const Text('Rechazar',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18),
                      label: const Text('Aceptar',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
      case 'confirmed':
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
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}