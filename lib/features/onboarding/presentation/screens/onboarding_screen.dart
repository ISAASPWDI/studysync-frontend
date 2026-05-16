// lib/features/onboarding/presentation/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../core/services/api_service.dart';

const _allSkills = [
  'HTML', 'CSS', 'JavaScript', 'TypeScript', 'React', 'Vue.js', 'Angular',
  'Next.js', 'Nuxt.js', 'Svelte', 'SvelteKit', 'Astro', 'Remix', 'Tailwind CSS',
  'Bootstrap', 'Material UI', 'Chakra UI', 'Sass/SCSS', 'Webpack', 'Vite',
  'Node.js', 'Express.js', 'NestJS', 'Fastify', 'Python', 'Django', 'FastAPI',
  'Flask', 'Java', 'Spring Boot', 'Kotlin', 'Ktor', 'C#', '.NET', 'ASP.NET',
  'Go', 'Gin', 'Fiber', 'Rust', 'Actix', 'Ruby', 'Ruby on Rails', 'PHP',
  'Laravel', 'Symfony', 'Elixir', 'Phoenix', 'Scala', 'Play Framework',
  'Flutter', 'Dart', 'Swift', 'SwiftUI', 'Objective-C', 'React Native',
  'Jetpack Compose', 'Kotlin Multiplatform', 'Ionic', 'Capacitor', 'Xamarin',
  'SQL', 'PostgreSQL', 'MySQL', 'SQLite', 'MariaDB', 'MongoDB', 'Redis',
  'Cassandra', 'DynamoDB', 'Firestore', 'Supabase', 'PlanetScale', 'Neo4j',
  'InfluxDB', 'Elasticsearch', 'CockroachDB',
  'Docker', 'Kubernetes', 'Terraform', 'Ansible', 'Jenkins', 'GitHub Actions',
  'GitLab CI', 'CircleCI', 'AWS', 'Azure', 'GCP', 'Vercel', 'Netlify',
  'DigitalOcean', 'Heroku', 'Nginx', 'Apache', 'Linux', 'Bash/Shell',
  'Python (ML)', 'TensorFlow', 'PyTorch', 'Keras', 'Scikit-learn', 'Pandas',
  'NumPy', 'Matplotlib', 'Jupyter', 'OpenCV', 'Hugging Face', 'LangChain',
  'OpenAI API', 'LlamaIndex', 'Spark', 'Hadoop', 'Airflow', 'dbt', 'Power BI',
  'Tableau', 'Looker', 'R', 'MATLAB',
  'Pentesting', 'Kali Linux', 'Metasploit', 'Burp Suite', 'Nmap', 'Wireshark',
  'OWASP', 'CTF', 'Criptografía', 'SIEM', 'Forense Digital',
  'Git', 'GitHub', 'GitLab', 'Bitbucket', 'Jira', 'Notion', 'Figma',
  'Postman', 'GraphQL', 'REST APIs', 'gRPC', 'WebSockets', 'OAuth2',
  'JWT', 'Microservices', 'Clean Architecture', 'TDD', 'DDD', 'SOLID',
  'Solidity', 'Ethereum', 'Web3.js', 'ethers.js', 'Hardhat', 'Foundry',
  'IPFS', 'Smart Contracts', 'Rust (Solana)',
  'Unity', 'C# (Unity)', 'Unreal Engine', 'C++ (Unreal)', 'Godot',
  'GDScript', 'Pygame', 'Three.js', 'WebGL', 'OpenGL',
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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  bool _loading = false;

  final _uniCtrl = TextEditingController();
  final _careerCtrl = TextEditingController();
  String? _semester;
  String? _district;
  final _bioCtrl = TextEditingController();
  final List<String> _selectedSkills = [];
  final List<String> _selectedInterests = [];
  final List<String> _selectedGoals = [];
  String? _availability;
  String? _groupSize;

  @override
  void initState() {
    super.initState();
    _uniCtrl.text = 'Universidad Nacional del Centro del Perú';
    _careerCtrl.text = 'Ingeniería de Sistemas';
  }

  @override
  void dispose() {
    _uniCtrl.dispose();
    _careerCtrl.dispose();
    _bioCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 5) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();

      final body = {
        'profile': {
          'university': _uniCtrl.text.trim(),
          'faculty': _careerCtrl.text.trim(),
          'semester': int.tryParse(_semester ?? ''),
          'location': {
            'district': _district,
            // 'coordinates': [-75.2, -12.0],
          },
          'bio': _bioCtrl.text.trim(),
        },
        'skills': {
          'technical': _selectedSkills,
          'interests': _selectedInterests,
        },
        'objectives': {
          'primary': _selectedGoals,
          'timeAvailability': _availability,
          'preferredGroupSize': _groupSize,
        },
      };

      debugPrint('ONBOARDING BODY: $body');
      await api.upsertProfile(body);

      final updatedUser = auth.user!.copyWith(
        university: _uniCtrl.text.trim(),
        career: _careerCtrl.text.trim(),
        semester: _semester,
        district: _district,
        technicalSkills: List.from(_selectedSkills),
        interestAreas: List.from(_selectedInterests),
        studyGoals: List.from(_selectedGoals),
        availability: _availability,
        groupSize: _groupSize,
        bio: _bioCtrl.text.trim(),
      );

      auth.updateUser(updatedUser);

      if (!mounted) return;
      context.go('/discover');
    } catch (e) {
      debugPrint('ONBOARDING ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.backgroundWhite),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _buildPersonalInfoPage(),
                  _buildSkillsPage(),
                  _buildInterestsPage(),
                  _buildGoalsPage(),
                  _buildStudyPreferencesPage(),
                  _buildReviewPage(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Información personal',
      'Habilidades técnicas',
      'Áreas de interés',
      'Objetivos de estudio',
      'Preferencias de estudio',
      'Resumen'
    ];
    final subtitles = [
      'Cuéntanos sobre ti y tu formación académica',
      'Selecciona tus tecnologías y herramientas favoritas',
      'Elige las áreas que más te apasionan',
      'Define qué quieres lograr en tu aprendizaje',
      'Configura cómo prefieres estudiar',
      'Revisa tu información antes de continuar'
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Paso ${_page + 1} de 6',
                  style: const TextStyle(
                    color: Color(AppColors.primaryBlue),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titles[_page],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitles[_page],
            style: const TextStyle(
              fontSize: 14,
              color: Color(AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(6, (i) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            height: 4,
            decoration: BoxDecoration(
              color: i <= _page
                  ? const Color(AppColors.primaryBlue)
                  : const Color(AppColors.divider),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInput(_uniCtrl, 'Universidad', Icons.school_outlined),
          const SizedBox(height: 14),
          _buildInput(_careerCtrl, 'Carrera', Icons.book_outlined),
          const SizedBox(height: 14),
          _buildDropdown('Semestre', _semester, _semesters, (v) => setState(() => _semester = v)),
          const SizedBox(height: 14),
          _buildInput(_buildDistrictController(), 'Distrito / Ciudad', Icons.location_on_outlined),
          const SizedBox(height: 14),
          _buildMultilineField(_bioCtrl, 'Bio (opcional) - Cuéntanos sobre ti'),
        ],
      ),
    );
  }

  Widget _buildSkillsPage() {
    return _SearchableChipSection(
      title: 'Habilidades técnicas',
      icon: Icons.code_outlined,
      all: _allSkills,
      selected: _selectedSkills,
      chipBg: const Color(AppColors.chipBlue),
      chipText: const Color(AppColors.chipBlueText),
      onChanged: () => setState(() {}),
    );
  }

  Widget _buildInterestsPage() {
    return _SearchableChipSection(
      title: 'Áreas de interés',
      icon: Icons.interests_outlined,
      all: _allInterests,
      selected: _selectedInterests,
      chipBg: const Color(AppColors.chipGreen),
      chipText: const Color(AppColors.chipGreenText),
      onChanged: () => setState(() {}),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
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
                  child: const Icon(
                    Icons.flag_outlined,
                    color: Color(0xFFF57C00),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Objetivos de estudio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._allGoals.map((g) => CheckboxListTile(
              title: Text(g, style: const TextStyle(fontSize: 14)),
              value: _selectedGoals.contains(g),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _selectedGoals.add(g);
                } else {
                  _selectedGoals.remove(g);
                }
              }),
              activeColor: const Color(AppColors.primaryBlue),
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDropdown('Disponibilidad', _availability, _availabilities, (v) => setState(() => _availability = v)),
                const SizedBox(height: 14),
                _buildDropdown('Tamaño de grupo preferido', _groupSize, _groupSizes, (v) => setState(() => _groupSize = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildReviewCard(
            'Información personal',
            Icons.person_outline,
            [
              'Universidad: ${_uniCtrl.text.isNotEmpty ? _uniCtrl.text : "No especificado"}',
              'Carrera: ${_careerCtrl.text.isNotEmpty ? _careerCtrl.text : "No especificado"}',
              'Semestre: ${_semester ?? "No especificado"}',
              'Distrito: ${_district ?? "No especificado"}',
              if (_bioCtrl.text.isNotEmpty) 'Bio: ${_bioCtrl.text}',
            ],
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'Habilidades técnicas',
            Icons.code_outlined,
            _selectedSkills.isEmpty ? ['No seleccionadas'] : _selectedSkills,
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'Áreas de interés',
            Icons.interests_outlined,
            _selectedInterests.isEmpty ? ['No seleccionadas'] : _selectedInterests,
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'Objetivos de estudio',
            Icons.flag_outlined,
            _selectedGoals.isEmpty ? ['No seleccionados'] : _selectedGoals,
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'Preferencias de estudio',
            Icons.school_outlined,
            [
              'Disponibilidad: ${_availability ?? "No especificada"}',
              'Tamaño de grupo: ${_groupSize ?? "No especificado"}',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, IconData icon, List<String> items) {
    return Container(
      width: double.infinity,
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
                child: Icon(icon, color: const Color(AppColors.primaryBlue), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '• $item',
              style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary)),
            ),
          )),
        ],
      ),
    );
  }

  TextEditingController _buildDistrictController() {
    final controller = TextEditingController(text: _district);
    controller.addListener(() {
      _district = controller.text;
    });
    return controller;
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(AppColors.textSecondary), size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.primaryBlue)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildMultilineField(TextEditingController ctrl, String hint) {
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.primaryBlue)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.primaryBlue)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_page > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(AppColors.primaryBlue)),
                ),
                child: const Text('Atrás', style: TextStyle(color: Color(AppColors.primaryBlue))),
              ),
            ),
          if (_page > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _loading ? null : _next,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_page == 5 ? 'Comenzar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }
}

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
      final others = widget.all.where((s) => !widget.selected.contains(s)).toList();
      final combined = [...widget.selected, ...others];
      return _expanded ? combined : combined.take(20).toList();
    }
    return widget.all.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hasMore = _query.isEmpty && !_expanded && (widget.all.length > 20);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
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
                    color: widget.chipBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.chipText, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
                  borderSide: const BorderSide(color: Color(AppColors.primaryBlue)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No se encontró "$_query"',
                  style: const TextStyle(color: Color(AppColors.textHint), fontSize: 13),
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
                        if (isSel) {
                          widget.selected.remove(s);
                        } else {
                          widget.selected.add(s);
                        }
                      });
                      widget.onChanged();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel
                            ? const Color(AppColors.primaryBlue)
                            : widget.chipBg,
                        borderRadius: BorderRadius.circular(20),
                        border: isSel
                            ? null
                            : Border.all(color: widget.chipText.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSel) ...[
                            const Icon(Icons.check, color: Colors.white, size: 13),
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
      ),
    );
  }
}