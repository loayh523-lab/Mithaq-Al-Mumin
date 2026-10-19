import 'package:flutter/material.dart';

void main() {
  runApp(const MeethaqApp());
}

const _background = Color(0xFF071A15);
const _surface = Color(0xFF102820);
const _surfaceLight = Color(0xFF18382D);
const _gold = Color(0xFFD6B875);
const _muted = Color(0xFFA6B8AE);

class MeethaqApp extends StatelessWidget {
  const MeethaqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ميثاق المؤمن',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _gold,
          brightness: Brightness.dark,
          surface: _surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _background,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF244438)),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    HomePage(),
    LibraryPage(
      title: 'القرآن الكريم',
      subtitle: 'مساحة القرآن الكريم',
      icon: Icons.menu_book_rounded,
      description: 'سيُضاف فهرس السور والقراءة والحفظ في المرحلة القادمة.',
    ),
    LibraryPage(
      title: 'الأدعية والزيارات',
      subtitle: 'زاد الروح',
      icon: Icons.auto_stories_rounded,
      description: 'ستُرتّب الأدعية والزيارات بحسب المصدر والمناسبة مع مراجعة النصوص.',
    ),
    TasbeehPage(),
    LibraryPage(
      title: 'الإعدادات',
      subtitle: 'تخصيص التطبيق',
      icon: Icons.tune_rounded,
      description: 'ستُضاف إعدادات الخط والتنبيهات والمظهر بعد تثبيت أساس التطبيق.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B211A),
        indicatorColor: _gold.withValues(alpha: 0.16),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: _gold),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: _gold),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded, color: _gold),
            label: 'الأدعية',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint_rounded),
            selectedIcon: Icon(Icons.fingerprint_rounded, color: _gold),
            label: 'التسبيح',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: _gold),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.45)),
              ),
              child: const Icon(Icons.nights_stay_rounded, color: _gold),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ميثاق المؤمن',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'رفيقك إلى الطمأنينة',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.notifications_none_rounded, color: _muted),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [_surfaceLight, _surface],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _gold.withValues(alpha: 0.32)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(color: _gold, fontSize: 16)),
              SizedBox(height: 18),
              Text(
                'وَقُلْ رَبِّ زِدْنِي عِلْمًا',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('طه، ١١٤', style: TextStyle(color: _muted, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const _SectionHeading(title: 'ابدأ يومك', subtitle: 'أبوابك الإيمانية'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: const [
            _FeatureCard(
              icon: Icons.menu_book_rounded,
              title: 'القرآن الكريم',
              subtitle: 'قراءة وتدبّر',
            ),
            _FeatureCard(
              icon: Icons.auto_stories_rounded,
              title: 'الأدعية والزيارات',
              subtitle: 'من مصادرها',
            ),
            _FeatureCard(
              icon: Icons.fingerprint_rounded,
              title: 'التسبيح',
              subtitle: 'اذكر الله بقلبك',
            ),
            _FeatureCard(
              icon: Icons.access_time_rounded,
              title: 'مواقيت الصلاة',
              subtitle: 'تُضاف في المرحلة القادمة',
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.favorite_border_rounded, color: _gold, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('خطوة صغيرة كل يوم',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 5),
                    Text(
                      'ابدأ بما تقدر عليه، واجعل لك وردًا ثابتًا.',
                      style: TextStyle(color: _muted, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _gold, size: 27),
            const Spacer(),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.35)),
              ),
              child: Icon(icon, size: 44, color: _gold),
            ),
            const SizedBox(height: 22),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: _gold)),
            const SizedBox(height: 16),
            Text(description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, height: 1.7)),
            const SizedBox(height: 22),
            const Chip(
              avatar: Icon(Icons.construction_rounded, size: 18, color: _gold),
              label: Text('قيد البناء على مراحل'),
              backgroundColor: _surface,
              side: BorderSide(color: Color(0xFF244438)),
            ),
          ],
        ),
      ),
    );
  }
}

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  int _count = 0;
  static const _target = 100;

  @override
  Widget build(BuildContext context) {
    final progress = (_count / _target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('التسبيح',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('سَبْحَانَ اللَّهِ', style: TextStyle(color: _gold, fontSize: 22)),
          const Spacer(),
          Text('$_count',
              style: const TextStyle(fontSize: 66, fontWeight: FontWeight.w800)),
          const Text('من $_target', style: TextStyle(color: _muted)),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: _surfaceLight,
              color: _gold,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            button: true,
            label: 'زيادة التسبيح',
            child: Material(
              color: _surfaceLight,
              shape: const CircleBorder(
                side: BorderSide(color: _gold, width: 2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _count++),
                child: const SizedBox(
                  width: 190,
                  height: 190,
                  child: Center(
                    child: Icon(Icons.fingerprint_rounded, color: _gold, size: 92),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _count >= _target ? 'أحسنت، أتممت مئة تسبيحة' : 'اضغط للعدّ',
            style: const TextStyle(color: _muted),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => setState(() => _count = 0),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تصفير العدّاد'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _gold,
              side: const BorderSide(color: _gold),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
