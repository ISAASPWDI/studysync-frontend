// lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../core/services/api_service.dart';

// ─── Catálogos completos ──────────────────────────────────────────────────────

const _allSkills = [
  // Frontend
  'HTML', 'CSS', 'JavaScript', 'TypeScript', 'React', 'Vue.js', 'Angular',
  'Next.js', 'Nuxt.js', 'Svelte', 'SvelteKit', 'Astro', 'Remix', 'Tailwind CSS',
  'Bootstrap', 'Material UI', 'Chakra UI', 'Sass/SCSS', 'Webpack', 'Vite',
  // Backend
  'Node.js', 'Express.js', 'NestJS', 'Fastify', 'Python', 'Django', 'FastAPI',
  'Flask', 'Java', 'Spring Boot', 'Kotlin', 'Ktor', 'C#', '.NET', 'ASP.NET',
  'Go', 'Gin', 'Fiber', 'Rust', 'Actix', 'Ruby', 'Ruby on Rails', 'PHP',
  'Laravel', 'Symfony', 'Elixir', 'Phoenix', 'Scala', 'Play Framework',
  // Mobile
  'Flutter', 'Dart', 'Swift', 'SwiftUI', 'Objective-C', 'React Native',
  'Jetpack Compose', 'Kotlin Multiplatform', 'Ionic', 'Capacitor', 'Xamarin',
  // Bases de datos
  'SQL', 'PostgreSQL', 'MySQL', 'SQLite', 'MariaDB', 'MongoDB', 'Redis',
  'Cassandra', 'DynamoDB', 'Firestore', 'Supabase', 'PlanetScale', 'Neo4j',
  'InfluxDB', 'Elasticsearch', 'CockroachDB',
  // DevOps & Cloud
  'Docker', 'Kubernetes', 'Terraform', 'Ansible', 'Jenkins', 'GitHub Actions',
  'GitLab CI', 'CircleCI', 'AWS', 'Azure', 'GCP', 'Vercel', 'Netlify',
  'DigitalOcean', 'Heroku', 'Nginx', 'Apache', 'Linux', 'Bash/Shell',
  // IA / ML / Data
  'Python (ML)', 'TensorFlow', 'PyTorch', 'Keras', 'Scikit-learn', 'Pandas',
  'NumPy', 'Matplotlib', 'Jupyter', 'OpenCV', 'Hugging Face', 'LangChain',
  'OpenAI API', 'LlamaIndex', 'Spark', 'Hadoop', 'Airflow', 'dbt', 'Power BI',
  'Tableau', 'Looker', 'R', 'MATLAB',
  // Ciberseguridad
  'Pentesting', 'Kali Linux', 'Metasploit', 'Burp Suite', 'Nmap', 'Wireshark',
  'OWASP', 'CTF', 'Criptografía', 'SIEM', 'Forense Digital',
  // Herramientas generales
  'Git', 'GitHub', 'GitLab', 'Bitbucket', 'Jira', 'Notion', 'Figma',
  'Postman', 'GraphQL', 'REST APIs', 'gRPC', 'WebSockets', 'OAuth2',
  'JWT', 'Microservices', 'Clean Architecture', 'TDD', 'DDD', 'SOLID',
  // Blockchain / Web3
  'Solidity', 'Ethereum', 'Web3.js', 'ethers.js', 'Hardhat', 'Foundry',
  'IPFS', 'Smart Contracts', 'Rust (Solana)',
  // Videojuegos
  'Unity', 'C# (Unity)', 'Unreal Engine', 'C++ (Unreal)', 'Godot',
  'GDScript', 'Pygame', 'Three.js', 'WebGL', 'OpenGL',
  // Otros
  'Electron', 'Tauri', 'WebAssembly', 'C', 'C++', 'Assembly', 'Prolog',
  'Haskell', 'Erlang', 'F#', 'Lua', 'Perl', 'COBOL', 'Fortran',
];

const _allInterests = [
  'Desarrollo Backend', 'Desarrollo Frontend', 'Desarrollo Full Stack',
  'Mobile (Android)', 'Mobile (iOS)', 'Mobile (Cross-Platform)',
  'Data Science', 'Machine Learning', 'Deep Learning', 'NLP / LLMs',
  'Computer Vision', 'MLOps', 'Data Engineering', 'Big Data', 'Analytics',
  'DevOps', 'SRE', 'Cloud Computing', 'Infraestructura', 'Serverless',
  'Ciberseguridad', 'Red Team', 'Blue Team', 'Ethical Hacking', 'Forense',
  'UI/UX Design', 'Product Design', 'Accesibilidad Web', 'Diseño de Sistemas',
  'Arquitectura de Software', 'Microservicios', 'Web3 / Blockchain',
  'Videojuegos', 'Realidad Virtual', 'Realidad Aumentada', 'IoT',
  'Robótica', 'Sistemas Embebidos', 'Bioinformática', 'FinTech', 'EdTech',
  'Open Source', 'Startups', 'Investigación Académica', 'Freelancing',
];

const _allGoals = [
  'Proyectos grupales',
  'Networking profesional',
  'Hackathons y competencias',
  'Preparación para exámenes',
  'Aprender nuevas tecnologías',
  'Mentoría (recibir)',
  'Mentoría (dar)',
  'Conseguir prácticas / internship',
  'Preparar portafolio',
  'Publicar en GitHub',
  'Contribuir a Open Source',
  'Preparar entrevistas técnicas',
  'Emprender un proyecto propio',
  'Certificaciones (AWS, GCP, etc.)',
  'Mejorar inglés técnico',
];

const _semesters = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
const _availabilities = ['Mañana', 'Tarde', 'Noche', 'Fines de semana', 'Flexible'];
const _groupSizes = ['Individual (1-1)', 'Pequeño (2-4)', 'Mediano (5-8)', 'Grande (9+)'];

// ─── Screen ───────────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _uniCtrl = TextEditingController();
  final _careerCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _semester;
  String? _availability;
  String? _groupSize;
  final List<String> _skills = [];
  final List<String> _interests = [];
  final List<String> _goals = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      // Set default university if empty
      _uniCtrl.text = user.university?.isNotEmpty == true
          ? user.university!
          : 'Universidad Nacional del Centro del Perú';
      // Set default career if empty
      _careerCtrl.text = user.career?.isNotEmpty == true
          ? user.career!
          : 'Ingeniería de Sistemas';
      _bioCtrl.text = user.bio ?? '';
      _semester = user.semester;
      _availability = user.availability;
      _groupSize = user.groupSize;
      _skills.addAll(user.technicalSkills);
      _interests.addAll(user.interestAreas);
      _goals.addAll(user.studyGoals);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _uniCtrl.dispose();
    _careerCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();

      await api.upsertProfile({
        'profile': {
          'university': auth.user!.university, 
          'faculty': auth.user!.career,
          'semester': int.tryParse(_semester ?? ''),
          'bio': _bioCtrl.text.trim(),
        },
        'skills': {
          'technical': _skills,
          'interests': _interests,
        },
        'objectives': {
          'primary': _goals,
          'timeAvailability': _availability,
          'preferredGroupSize': _groupSize,
        },
      });

      final updated = auth.user!.copyWith(
        name: _nameCtrl.text.trim(),
        university: _uniCtrl.text.trim(),
        career: _careerCtrl.text.trim(),
        semester: _semester,
        technicalSkills: List.from(_skills),
        interestAreas: List.from(_interests),
        studyGoals: List.from(_goals),
        availability: _availability,
        groupSize: _groupSize,
        bio: _bioCtrl.text.trim(),
      );
      auth.updateUser(updated);

      await api.syncProfile();

      if (!mounted) return;
      Navigator.pop(context);
      _showToast(context, '✓ Perfil actualizado correctamente', success: true);
    } catch (e) {
      if (!mounted) return;
      _showToast(context, '✗ Error al guardar el perfil', success: false);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showToast(BuildContext context, String message, {required bool success}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        success: success,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.surfaceGrey),
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryBlue),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section('Información básica', [
              _field(_nameCtrl, 'Nombre completo', Icons.person_outline),
              _field(_uniCtrl, 'Universidad', Icons.school_outlined, disabled: true),
              _field(_careerCtrl, 'Carrera', Icons.book_outlined, disabled: true),
              _dropdown('Semestre', _semester, _semesters, (v) => setState(() => _semester = v)),
              _multilineField(_bioCtrl, 'Bio / Descripción personal'),
            ]),
            const SizedBox(height: 12),
            _section('Preferencias de estudio', [
              _dropdown(
                  'Disponibilidad', _availability, _availabilities, (v) => setState(() => _availability = v)),
              _dropdown(
                  'Tamaño de grupo preferido', _groupSize, _groupSizes, (v) => setState(() => _groupSize = v)),
            ]),
            const SizedBox(height: 12),
            _SearchableChipSection(
              title: 'Habilidades técnicas',
              icon: Icons.code_outlined,
              all: _allSkills,
              selected: _skills,
              chipBg: const Color(AppColors.chipBlue),
              chipText: const Color(AppColors.chipBlueText),
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            _SearchableChipSection(
              title: 'Áreas de interés',
              icon: Icons.interests_outlined,
              all: _allInterests,
              selected: _interests,
              chipBg: const Color(AppColors.chipGreen),
              chipText: const Color(AppColors.chipGreenText),
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            _goalSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(AppColors.textPrimary)),
          ),
          const SizedBox(height: 14),
          ...children
              .expand((w) => [w, const SizedBox(height: 12)])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }
  Widget _field(TextEditingController ctrl, String hint, IconData icon, {bool disabled = false}) {
    return TextField(
      controller: ctrl,
      enabled: !disabled,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(AppColors.textSecondary), size: 20),
        filled: disabled,
        fillColor: disabled ? const Color(AppColors.surfaceGrey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _multilineField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider)),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider)),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _goalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                child: const Icon(Icons.flag_outlined,
                    color: Color(0xFFF57C00), size: 16),
              ),
              const SizedBox(width: 8),
              const Text('Objetivos de estudio',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ..._allGoals.map((g) => CheckboxListTile(
            title: Text(g, style: const TextStyle(fontSize: 14)),
            value: _goals.contains(g),
            onChanged: (v) =>
                setState(() => v! ? _goals.add(g) : _goals.remove(g)),
            activeColor: const Color(AppColors.primaryBlue),
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
        ],
      ),
    );
  }
}

// ─── SearchableChipSection ────────────────────────────────────────────────────

class _SearchableChipSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> all;
  final List<String> selected;
  final Color chipBg;
  final Color chipText;
  final VoidCallback onChanged;

  const _SearchableChipSection({
    required this.title,
    required this.icon,
    required this.all,
    required this.selected,
    required this.chipBg,
    required this.chipText,
    required this.onChanged,
  });

  @override
  State<_SearchableChipSection> createState() => _SearchableChipSectionState();
}

class _SearchableChipSectionState extends State<_SearchableChipSection> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _expanded = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) {
      // Show selected first, then others (up to 20 if not expanded)
      final others = widget.all.where((s) => !widget.selected.contains(s)).toList();
      final combined = [...widget.selected, ...others];
      return _expanded ? combined : combined.take(20).toList();
    }
    return widget.all.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hasMore = _query.isEmpty &&
        !_expanded &&
        (widget.all.length > 20);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.chipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.chipText, size: 16),
              ),
              const SizedBox(width: 8),
              Text(widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (widget.selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primaryBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.selected.length} seleccionados',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Buscar en ${widget.title.toLowerCase()}...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(AppColors.divider)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(AppColors.divider)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: Color(AppColors.primaryBlue)),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          // Chips
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No se encontró "$_query"',
                style: const TextStyle(
                    color: Color(AppColors.textHint), fontSize: 13),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filtered.map((s) {
                final isSel = widget.selected.contains(s);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSel ? widget.selected.remove(s) : widget.selected.add(s);
                    });
                    widget.onChanged();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(AppColors.primaryBlue)
                          : widget.chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: isSel
                          ? null
                          : Border.all(
                          color: widget.chipText.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSel) ...[
                          const Icon(Icons.check,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          s,
                          style: TextStyle(
                            color: isSel ? Colors.white : widget.chipText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          // Show more / less
          if (hasMore || (_expanded && _query.isEmpty)) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded
                        ? 'Ver menos'
                        : 'Ver más (${widget.all.length - 20} más)',
                    style: const TextStyle(
                      color: Color(AppColors.primaryBlue),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(AppColors.primaryBlue),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Toast Widget ─────────────────────────────────────────────────────────────

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool success;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.success,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40 + MediaQuery.of(context).padding.bottom,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: widget.success
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (widget.success
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828))
                        .withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.success ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
}