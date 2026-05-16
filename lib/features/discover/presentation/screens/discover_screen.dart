// lib/features/discover/presentation/screens/discover_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<RecommendedUser> _users = [];
  bool _loading = true;
  bool _swiping = false;

  late AnimationController _swipeCtrl;
  late Animation<Offset> _swipeAnim;
  late Animation<double> _rotateAnim;
  late AnimationController _matchCtrl;
  late Animation<double> _matchAnim;

  Offset _dragOffset = Offset.zero;
  bool _showLike = false;
  bool _showPass = false;
  bool _showMatch = false;
  String? _matchName;

  @override
  void initState() {
    super.initState();
    _swipeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _swipeAnim =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_swipeCtrl);
    _rotateAnim = Tween<double>(begin: 0, end: 0).animate(_swipeCtrl);

    _matchCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _matchAnim = CurvedAnimation(parent: _matchCtrl, curve: Curves.elasticOut);

    _loadUsers();
  }

  @override
  void dispose() {
    _swipeCtrl.dispose();
    _matchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _api.getRecommendations(limit: 10);
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_swiping) return;
    setState(() {
      _dragOffset += d.delta;
      _showLike = _dragOffset.dx > 55;
      _showPass = _dragOffset.dx < -55;
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_swiping) return;
    if (_dragOffset.dx.abs() > 90) {
      _animateSwipe(_dragOffset.dx > 0);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _showLike = false;
        _showPass = false;
      });
    }
  }

  void _animateSwipe(bool isLike) async {
    if (_swiping || _users.isEmpty) return;
    _swiping = true;

    final screenW = MediaQuery.of(context).size.width;
    final target = isLike
        ? Offset(screenW * 1.6, -80.0)
        : Offset(-screenW * 1.6, -80.0);

    _swipeAnim = Tween<Offset>(begin: _dragOffset, end: target).animate(
        CurvedAnimation(parent: _swipeCtrl, curve: Curves.easeOut));
    _rotateAnim =
        Tween<double>(begin: _dragOffset.dx / 500, end: isLike ? 0.28 : -0.28)
            .animate(_swipeCtrl);

    _swipeCtrl.forward(from: 0).then((_) async {
      final user = _users.first;
      setState(() {
        _users.removeAt(0);
        _dragOffset = Offset.zero;
        _showLike = false;
        _showPass = false;
        _swiping = false;
      });
      _swipeCtrl.reset();

      try {
        final result = await _api.swipeAction(
          targetUserId: user.userId,
          action: isLike ? 'like' : 'dislike',
          matchScore: user.matchScore,
        );
        if (result.isMatch && mounted) {
          setState(() {
            _showMatch = true;
            _matchName = user.name;
          });
          _matchCtrl.forward(from: 0);
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            setState(() => _showMatch = false);
            _matchCtrl.reset();
          }
        }
      } catch (_) {}

      if (_users.isEmpty) _loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _loading
                    ? const _LoadingWidget()
                    : _users.isEmpty
                    ? _EmptyWidget(onRefresh: _loadUsers)
                    : _buildSwipeArea(),
              ),
            ],
          ),
          if (_showMatch) _buildMatchOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded,
              color: Color(AppColors.primaryBlue), size: 28),
          const SizedBox(width: 8),
          const Text(
            'StudySync',
            style: TextStyle(
              color: Color(AppColors.primaryBlue),
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (!_loading && _users.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryBlue).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_users.length} perfiles',
                style: const TextStyle(
                  color: Color(AppColors.primaryBlue),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(AppColors.primaryBlue), size: 22),
            onPressed: _loadUsers,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeArea() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_users.length > 2)
                Positioned(
                  top: 28, left: 28, right: 28, bottom: 0,
                  child: _buildBackCard(scale: 0.91, opacity: 0.45),
                ),
              if (_users.length > 1)
                Positioned(
                  top: 14, left: 18, right: 18, bottom: 0,
                  child: _buildBackCard(scale: 0.96, opacity: 0.7),
                ),
              AnimatedBuilder(
                animation: _swipeCtrl,
                builder: (_, __) {
                  final offset = _swipeCtrl.isAnimating
                      ? _swipeAnim.value
                      : _dragOffset;
                  final rotate = _swipeCtrl.isAnimating
                      ? _rotateAnim.value
                      : _dragOffset.dx / 500;
                  return Positioned(
                    top: 0, left: 0, right: 0, bottom: 0,
                    child: Transform.translate(
                      offset: offset,
                      child: Transform.rotate(
                        angle: rotate,
                        child: GestureDetector(
                          onPanUpdate: _onDragUpdate,
                          onPanEnd: _onDragEnd,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                            child: Stack(
                              children: [
                                _buildMainCard(_users.first),
                                if (_showLike)
                                  _buildSwipeLabel('CONECTAR', Colors.green,
                                      Alignment.topLeft),
                                if (_showPass)
                                  _buildSwipeLabel('PASAR', Colors.red,
                                      Alignment.topRight),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildBackCard({double scale = 1, double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(RecommendedUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryBlue).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(user),
              _buildInfoSection(user),
              _buildDetailsSection(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(RecommendedUser user) {
    final score = user.matchScore;
    final scoreColor = score >= 0.7
        ? Colors.green.shade600
        : score >= 0.5
        ? const Color(AppColors.primaryBlue)
        : Colors.orange.shade600;

    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(AppColors.primaryBlue).withOpacity(0.13),
                const Color(AppColors.primaryBlue).withOpacity(0.04),
              ],
            ),
          ),
          child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? Image.network(
            user.avatarUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildInitialAvatar(user),
          )
              : _buildInitialAvatar(user),
        ),
        // Badge compatibilidad — icono académico
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: scoreColor.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    color: scoreColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${(score * 100).toInt()}% compatible',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Online badge
        if (user.isOnline)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 7),
                  SizedBox(width: 4),
                  Text('En línea',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialAvatar(RecommendedUser user) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(AppColors.primaryBlue),
              const Color(AppColors.primaryBlue).withOpacity(0.65),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(AppColors.primaryBlue).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 34,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(RecommendedUser user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(AppColors.textPrimary),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user.showSemester && user.semester > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ciclo ${user.semester}',
                    style: const TextStyle(
                      color: Color(AppColors.primaryBlue),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          if (user.faculty != null || user.university != null)
            Row(
              children: [
                const Icon(Icons.school_rounded,
                    size: 13, color: Color(AppColors.textSecondary)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _buildUniText(user),
                    style: const TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (user.showLocation &&
              user.location != null &&
              user.location!.isNotEmpty &&
              user.location != 'Sin ubicación')
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 13, color: Color(AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Text(
                    _capitalize(user.location!),
                    style: const TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (user.technicalSkills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: user.technicalSkills.take(5).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.chipBlue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      color: Color(AppColors.chipBlueText),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection(RecommendedUser user) {
    final hasDetails = (user.bio != null && user.bio!.isNotEmpty) ||
        user.interestAreas.isNotEmpty ||
        user.objectives.isNotEmpty ||
        user.timeAvailability != 'No especificado' ||
        user.preferredGroupSize != 'No especificado';

    if (!hasDetails) return const SizedBox(height: 16);

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            _sectionLabel('Sobre mí'),
            const SizedBox(height: 5),
            Text(
              user.bio!,
              style: const TextStyle(
                color: Color(AppColors.textSecondary),
                fontSize: 13,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          if (user.timeAvailability != 'No especificado' ||
              user.preferredGroupSize != 'No especificado') ...[
            Row(
              children: [
                if (user.timeAvailability != 'No especificado')
                  Expanded(
                    child: _infoChip(
                      Icons.schedule_rounded,
                      user.timeAvailability,
                      const Color(0xFFFFF8ED),
                      Colors.orange.shade700,
                    ),
                  ),
                if (user.timeAvailability != 'No especificado' &&
                    user.preferredGroupSize != 'No especificado')
                  const SizedBox(width: 8),
                if (user.preferredGroupSize != 'No especificado')
                  Expanded(
                    child: _infoChip(
                      Icons.group_rounded,
                      user.preferredGroupSize,
                      const Color(0xFFEDF7EE),
                      Colors.green.shade700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (user.interestAreas.isNotEmpty) ...[
            _sectionLabel('Intereses'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: user.interestAreas.take(4).map((i) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.purple.withOpacity(0.18), width: 1),
                  ),
                  child: Text(
                    i,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          if (user.objectives.isNotEmpty) ...[
            _sectionLabel('Objetivos'),
            const SizedBox(height: 6),
            ...user.objectives.take(3).map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 13,
                      color: const Color(AppColors.primaryBlue)
                          .withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      o,
                      style: const TextStyle(
                        color: Color(AppColors.textSecondary),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: const Color(AppColors.primaryBlue).withOpacity(0.65),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeLabel(
      String text, Color color, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Transform.rotate(
          angle: alignment == Alignment.topLeft ? -0.25 : 0.25,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(8),
              color: color.withOpacity(0.08),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: Icons.close_rounded,
            color: Colors.red.shade400,
            size: 64,
            label: 'Pasar',
            onTap: () => _animateSwipe(false),
          ),
          _ActionBtn(
            icon: Icons.menu_book_rounded,
            color: const Color(AppColors.primaryBlue),
            size: 72,
            label: 'Conectar',
            onTap: () => _animateSwipe(true),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() => _showMatch = false);
        _matchCtrl.reset();
      },
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: ScaleTransition(
            scale: _matchAnim,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.primaryBlue).withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      size: 56, color: Color(AppColors.primaryBlue)),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Es un Match!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tú y $_matchName pueden comenzar a estudiar juntos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _showMatch = false);
                        _matchCtrl.reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryBlue),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver matches',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildUniText(RecommendedUser user) {
    final parts = [user.faculty, user.university]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.join(' · ');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.size,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.22), width: 1.5),
            ),
            child: Icon(icon, color: color, size: size * 0.44),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: Color(AppColors.primaryBlue),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Buscando compañeros...',
            style: TextStyle(
              color: Color(AppColors.textSecondary),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyWidget({required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryBlue).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 42,
                color: Color(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin perfiles por ahora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vuelve más tarde para ver nuevos compañeros de estudio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(AppColors.textSecondary),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Actualizar',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}