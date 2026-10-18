import 'package:flutter/material.dart';

void main() {
  runApp(const MithaqApp());
}

const Color deepGreen = Color(0xFF071F1A);
const Color panelGreen = Color(0xFF10372E);
const Color accentGold = Color(0xFFD9B66D);

class MithaqApp extends StatelessWidget {
  const MithaqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميثاق المؤمن',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentGold,
          brightness: Brightness.dark,
          surface: panelGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: deepGreen,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_FeatureItem>[
      _FeatureItem(Icons.menu_book_rounded, 'القرآن الكريم', 'قراءة وتدبر'),
      _FeatureItem(Icons.access_time_rounded, 'مواقيت الصلاة', 'الأوقات والأذان'),
      _FeatureItem(Icons.volunteer_activism_rounded, 'الأدعية', 'أذكار وأدعية'),
      _FeatureItem(Icons.mosque_rounded, 'الزيارات', 'نصوص الزيارات'),
      _FeatureItem(Icons.explore_rounded, 'اتجاه القبلة', 'تحديد اتجاه القبلة'),
      _FeatureItem(Icons.local_library_rounded, 'المكتبة الإسلامية', 'كتب ومصادر موثوقة'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ميثاق المؤمن', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('رفيقك في العبادة والمعرفة',
                style: TextStyle(fontSize: 12, color: accentGold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => _showNotice(context, 'الإعدادات ستضاف لاحقاً'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF17483A), Color(0xFF0D2B24)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                border: Border.all(color: accentGold.withValues(alpha: 0.35)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.nights_stay_rounded, color: accentGold, size: 34),
                  SizedBox(height: 16),
                  Text('السلام عليكم ورحمة الله',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('مساحة تجمع ما يعينك على العبادة وطلب المعرفة الإسلامية الموثوقة.',
                      style: TextStyle(height: 1.6, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('أقسام التطبيق',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showNotice(context, 'قسم ${item.title} قيد التطوير'),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: panelGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: accentGold, size: 30),
                        const SizedBox(height: 12),
                        Text(item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 5),
                        Text(item.subtitle,
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'تنبيه: هذه نسخة أولية. لا تعرض مواقيت أو نصوصاً دينية معتمدة حتى تتم إضافة مصادرها والتحقق منها.',
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FeatureItem {
  const _FeatureItem(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}
