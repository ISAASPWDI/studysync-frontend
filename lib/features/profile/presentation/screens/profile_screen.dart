// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(AppColors.surfaceGrey),
      body: CustomScrollView(
        slivers: [
          // Sticky header with custom app bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: const Color(AppColors.primaryBlue),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate collapse percentage
                final collapsePercentage = (1 - (constraints.maxHeight - 80) / (300 - 80))
                    .clamp(0.0, 1.0);

                // Show collapsed title only when scrolled enough
                final showCollapsedTitle = collapsePercentage > 0.5;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background (always visible)
                    Container(color: const Color(AppColors.primaryBlue)),

                    // Full header (fades out as we scroll)
                    if (!showCollapsedTitle)
                      Opacity(
                        opacity: 1.0 - collapsePercentage,
                        child: SingleChildScrollView(
                          child: _buildHeader(context, user),
                        ),
                      ),

                    // Collapsed title (centered)
                    if (showCollapsedTitle)
                      FadeTransition(
                        opacity: AlwaysStoppedAnimation(collapsePercentage),
                        child: Center(
                          child: _buildCollapsedTitle(user),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                if (user.technicalSkills.isNotEmpty || user.interestAreas.isNotEmpty || user.studyGoals.isNotEmpty) ...[
                  if (user.technicalSkills.isNotEmpty) _buildSkillsCard(user),
                  if (user.technicalSkills.isNotEmpty) const SizedBox(height: 8),
                  if (user.interestAreas.isNotEmpty) _buildInterestsCard(user),
                  if (user.interestAreas.isNotEmpty) const SizedBox(height: 8),
                  if (user.studyGoals.isNotEmpty) _buildGoalsCard(user),
                  if (user.studyGoals.isNotEmpty) const SizedBox(height: 8),
                ] else ...[
                  _buildEmptyProfileCard(context),
                  const SizedBox(height: 8),
                ],
                _buildMenuSection(context, user),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedTitle(UserModel user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Small avatar for collapsed state
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: user.avatarUrl != null
                ? Image.network(
              user.avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitialAvatar(user),
            )
                : _buildInitialAvatar(user),
          ),
        ),
        const SizedBox(width: 8),
        // User name
        Flexible(
          child: Text(
            user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAvatar(UserModel user) {
    return Center(
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Changed to center
        mainAxisSize: MainAxisSize.min, // Added this to prevent overflow
        children: [
          // Edit button row - aligned to the right
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => context.push('/edit-profile'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.primaryBlue),
              ),
            )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (user.career != null || user.university != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                [user.career, user.university]
                    .where((e) => e != null && e.isNotEmpty)
                    .join(' · '),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          if (user.semester != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Semestre ${user.semester}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
          // Stats row
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatChip(Icons.code_outlined, '${user.technicalSkills.length}', 'habilidades'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.interests_outlined, '${user.interestAreas.length}', 'intereses'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.flag_outlined, '${user.studyGoals.length}', 'objetivos'),
              ],
            ),
          ),
          const SizedBox(height: 8), // Added bottom spacing
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(UserModel user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(AppColors.chipBlue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code_outlined, color: Color(AppColors.primaryBlue), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Habilidades técnicas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(AppColors.chipBlue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${user.technicalSkills.length}',
                  style: const TextStyle(
                    color: Color(AppColors.primaryBlue),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.technicalSkills
                .map((s) => _SkillChip(label: s, blue: true))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsCard(UserModel user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(AppColors.chipGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.interests_outlined, color: Color(AppColors.chipGreenText), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Áreas de interés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(AppColors.chipGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${user.interestAreas.length}',
                  style: const TextStyle(
                    color: Color(AppColors.chipGreenText),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.interestAreas
                .map((s) => _SkillChip(label: s, blue: false))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard(UserModel user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flag_outlined, color: Color(0xFFF57C00), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Objetivos de estudio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...user.studyGoals.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.chipBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(AppColors.primaryBlue),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(g, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          )),
          if (user.availability != null || user.groupSize != null) ...[
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
            if (user.availability != null)
              _InfoRow(
                icon: Icons.access_time_outlined,
                label: 'Disponibilidad',
                value: user.availability!,
              ),
            if (user.groupSize != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.people_outline,
                label: 'Tamaño de grupo',
                value: user.groupSize!,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(AppColors.divider)),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_add_outlined, color: Color(AppColors.textHint), size: 40),
          const SizedBox(height: 10),
          const Text(
            'Completa tu perfil',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Agrega tus habilidades, áreas de interés y objetivos para conectar mejor con otros estudiantes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 13),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/edit-profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Editar perfil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, UserModel user) {
    final auth = context.read<AuthProvider>();
    final items = [
      _MenuItem(
        icon: Icons.person_outline,
        title: AppStrings.editProfile,
        subtitle: 'Actualiza tu información',
        onTap: () => context.push('/edit-profile'),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: AppStrings.notifications,
        subtitle: 'Configurar alertas y recordatorios',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.security_outlined,
        title: AppStrings.privacy,
        subtitle: 'Controla quién puede verte',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: AppStrings.settings,
        subtitle: 'Preferencias generales',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: AppStrings.helpSupport,
        subtitle: 'Obtén ayuda o reporta problemas',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.info_outline,
        title: AppStrings.about,
        subtitle: 'Información de la app',
        onTap: () {},
      ),
    ];

    return Column(
      children: [
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildMenuTile(item),
        )),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildLogoutTile(context, auth),
        ),
      ],
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(AppColors.chipBlue),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: const Color(AppColors.primaryBlue), size: 22),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          item.subtitle,
          style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(AppColors.textHint)),
        onTap: item.onTap,
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.logout, color: Color(AppColors.error), size: 22),
        ),
        title: const Text(
          AppStrings.logout,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(AppColors.error)),
        ),
        subtitle: const Text(
          'Salir de la aplicación',
          style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(AppColors.textHint)),
        onTap: () {
          showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(  // ← usar dialogContext
              title: const Text('Cerrar sesión'),
              content: const Text('¿Estás seguro que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),  // ← dialogContext
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),   // ← dialogContext
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Color(AppColors.error)),
                  ),
                ),
              ],
            ),
          ).then((confirm) async {
            if (confirm == true) {
              await auth.logout();
              if (context.mounted) {
                context.go('/login');
              }
            }
          });
        },
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final bool blue;
  const _SkillChip({required this.label, required this.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: blue ? const Color(AppColors.chipBlue) : const Color(AppColors.chipGreen),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: blue
              ? const Color(AppColors.chipBlueText)
              : const Color(AppColors.chipGreenText),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(AppColors.textSecondary), size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}