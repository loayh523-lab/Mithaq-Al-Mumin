import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MithaqApp());

const deepGreen = Color(0xFF071F1A);
const panelGreen = Color(0xFF10372E);
const accentGold = Color(0xFFD9B66D);

class MithaqApp extends StatelessWidget {
  const MithaqApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ميثاق المؤمن',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: deepGreen,
      colorScheme: ColorScheme.fromSeed(seedColor: accentGold, brightness: Brightness.dark)),
    home: const Directionality(textDirection: TextDirection.rtl, child: HomePage()),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final features = [
      ['القرآن الكريم', 'قراءة سور مختارة', Icons.menu_book, 'quran'],
      ['مواقيت الصلاة', 'حساب أوقات الصلاة', Icons.access_time, 'prayer'],
      ['الأدعية والأذكار', 'تسبيح واستغفار وصلاة', Icons.volunteer_activism, 'adhkar'],
      ['تسبيح الزهراء عليها السلام', '34 تكبيراً و33 تحميداً و33 تسبيحاً', Icons.auto_awesome, 'fatima_tasbih'],
      ['الزيارات', 'الزيارات الكاملة ومصادرها', Icons.mosque, 'ziyarat'],
      ['اتجاه القبلة', 'حساب اتجاه القبلة', Icons.explore, 'qibla'],
      ['المكتبة الإسلامية', 'مصادر وكتب موثوقة', Icons.local_library, 'library'],
      ['المسبحة الإلكترونية', 'تسبيح مع عدّاد', Icons.circle_outlined, 'tasbih'],
      ['المسائل الشرعية', 'مواقع المراجع للاستفتاء', Icons.gavel, 'fiqh'],
      ['التقويم الهجري', 'التاريخ الهجري التقريبي', Icons.calendar_month, 'hijri'],
    ];
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ميثاق المؤمن', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('رفيقك في العبادة والمعرفة', style: TextStyle(fontSize: 12, color: accentGold)),
      ])),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF17483A), Color(0xFF0D2B24)]),
            border: Border.all(color: accentGold.withValues(alpha: .35))),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.nights_stay, color: accentGold, size: 34),
            SizedBox(height: 16),
            Text('السلام عليكم ورحمة الله', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('مساحة تجمع ما يعينك على العبادة وطلب المعرفة الإسلامية الموثوقة.',
              style: TextStyle(height: 1.6, color: Colors.white70)),
          ])),
        const SizedBox(height: 24),
        const Text('أقسام التطبيق', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.05),
          itemBuilder: (context, index) {
            final f = features[index];
            return InkWell(borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (f[3] == 'quran') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const QuranPage()));
                } else if (f[3] == 'tasbih') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const TasbihPage()));
                } else if (f[3] == 'adhkar') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AdhkarPage()));
                } else if (f[3] == 'fatima_tasbih') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const FatimaTasbihPage()));
                } else if (f[3] == 'ziyarat') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ZiyaratPage()));
                } else if (f[3] == 'prayer') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PrayerTimesPage()));
                } else if (f[3] == 'qibla') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const QiblaPage()));
                } else if (f[3] == 'library') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const IslamicLibraryPage()));
                } else if (f[3] == 'fiqh') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const FiqhSourcesPage()));
                } else if (f[3] == 'hijri') {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const HijriCalendarPage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('قسم ' + (f[0] as String) + ' قيد التطوير')));
                }
              },
              child: Ink(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: panelGreen, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: .07))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(f[2] as IconData, color: accentGold, size: 30),
                  const SizedBox(height: 12),
                  Text(f[0] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(f[1] as String, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ])));
          }),
        const SizedBox(height: 18),
        const Text('نسخة قيد التطوير: تتوفر سور مختارة، والمسبحة، والأذكار، وزيارة الأربعين دون إنترنت، ومواقيت صلاة محسوبة تقريبياً. الأذان والقبلة وبقية النصوص قيد الاستكمال والمراجعة.',
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
      ]),
    );
  }
}

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<Surah> surahs = [];
  bool loading = true;
  String? error;
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    try {
      final raw = await rootBundle.loadString('assets/quran/quran-uthmani.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final rows = decoded['surahs'] as List<dynamic>;
      final loaded = rows.map((row) {
        final item = row as Map<String, dynamic>;
        final ayahs = (item['ayahs'] as List<dynamic>)
            .where((a) => ((a as Map<String, dynamic>)['number'] as num).toInt() > 0)
            .map((a) => (a as Map<String, dynamic>)['text'] as String)
            .toList(growable: false);
        return Surah(item['name'] as String, (item['number'] as num).toInt(), ayahs);
      }).toList(growable: false);
      if (loaded.length != 114) throw const FormatException('عدد السور غير مكتمل');
      if (!mounted) return;
      setState(() { surahs = loaded; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { loading = false; error = 'تعذر تحميل ملف القرآن المضمّن. أعد بناء التطبيق بعد تنزيل ملف المصدر.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = surahs.where((s) => s.name.contains(query.trim()) || s.number.toString() == query.trim()).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('القرآن الكريم')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!, textAlign: TextAlign.center)))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      onChanged: (v) => setState(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سورة أو رقمها',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: panelGreen,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('النص العثماني من مشروع تنزيل Tanzil. يعمل ملف القرآن دون إنترنت بعد تثبيت التطبيق.',
                      style: TextStyle(color: Colors.white60, height: 1.5)),
                  ),
                  Expanded(child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      return Card(
                        color: panelGreen,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: deepGreen, child: Text(s.number.toString(), style: const TextStyle(color: accentGold))),
                          title: Text('سورة ' + s.name),
                          subtitle: Text(s.verses.length.toString() + ' آيات'),
                          trailing: const Icon(Icons.chevron_left, color: accentGold),
                          onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SurahPage(surah: s))),
                        ),
                      );
                    },
                  )),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('المصدر: Tanzil.net — CC BY 3.0', style: TextStyle(fontSize: 11, color: Colors.white38)),
                  ),
                ]),
    );
  }
}

class Surah {
  const Surah(this.name, this.number, this.verses);
  final String name;
  final int number;
  final List<String> verses;
}

class SurahPage extends StatelessWidget {
  const SurahPage({super.key, required this.surah});
  final Surah surah;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('سورة ' + surah.name)),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      Center(child: Text('سورة ' + surah.name, style: const TextStyle(color: accentGold, fontSize: 24, fontWeight: FontWeight.bold))),
      const SizedBox(height: 24),
      if (surah.number != 1 && surah.number != 9)
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: TextStyle(color: accentGold, fontSize: 25, height: 1.8)),
        ),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: panelGreen, borderRadius: BorderRadius.circular(22), border: Border.all(color: accentGold.withValues(alpha: .25))),
        child: Column(children: [
          for (var i = 0; i < surah.verses.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                '${surah.verses[i]}  ﴿${i + 1}﴾',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 25, height: 2.0),
              ),
            ),
        ])),
      const SizedBox(height: 16),
      const Text('النص العثماني: مشروع تنزيل Tanzil. أُبقي النص كما ورد في المصدر؛ قد تختلف علامات العرض عن مصحفك المطبوع.',
        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
    ]),
  );
}


class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key});
  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  final List<Map<String, Object>> adhkar = const [
    {'title': 'الصلاة على محمد وآل محمد', 'text': 'اللهم صل على محمد وآل محمد', 'target': 100},
    {'title': 'الاستغفار', 'text': 'أستغفر الله ربي وأتوب إليه', 'target': 100},
    {'title': 'التسبيح', 'text': 'سبحان الله والحمد لله ولا إله إلا الله والله أكبر', 'target': 100},
  ];
  int selected = 0;
  int count = 0;
  final List<int> savedCounts = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      selected = (prefs.getInt('adhkar_selected') ?? 0).clamp(0, adhkar.length - 1);
      for (var i = 0; i < savedCounts.length; i++) {
        savedCounts[i] = prefs.getInt('adhkar_count_$i') ?? 0;
      }
      count = savedCounts[selected];
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('adhkar_selected', selected);
    await prefs.setInt('adhkar_count_$selected', count);
  }

  @override
  Widget build(BuildContext context) {
    final item = adhkar[selected];
    final target = item['target'] as int;
    return Scaffold(
      appBar: AppBar(title: const Text('الأدعية والأذكار')),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('اختر الذكر', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(adhkar.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                color: selected == i ? const Color(0xFF17483A) : panelGreen,
                child: ListTile(
                  title: Text(adhkar[i]['title'] as String),
                  trailing: selected == i ? const Icon(Icons.check_circle, color: accentGold) : null,
                  onTap: () { setState(() { selected = i; count = savedCounts[i]; }); _saveProgress(); },
                ),
              ),
            )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: panelGreen, borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accentGold.withValues(alpha: .25))),
              child: Column(children: [
                Text(item['text'] as String, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, height: 1.8, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                Text(count.toString(), style: const TextStyle(fontSize: 54, color: accentGold, fontWeight: FontWeight.bold)),
                Text('من ' + target.toString(), style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: (count / target).clamp(0.0, 1.0),
                  minHeight: 6, borderRadius: BorderRadius.circular(10), color: accentGold,
                  backgroundColor: Colors.white12),
              ]),
            ),
            const SizedBox(height: 18),
            SizedBox(height: 58, child: FilledButton.icon(
              onPressed: () { setState(() { if (count < target) count++; savedCounts[selected] = count; }); _saveProgress(); },
              icon: const Icon(Icons.touch_app),
              label: const Text('سبّح', style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(backgroundColor: accentGold, foregroundColor: deepGreen),
            )),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () { setState(() { count = 0; savedCounts[selected] = 0; }); _saveProgress(); },
              icon: const Icon(Icons.restart_alt), label: const Text('تصفير العدّاد'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class FatimaTasbihPage extends StatefulWidget {
  const FatimaTasbihPage({super.key});

  @override
  State<FatimaTasbihPage> createState() => _FatimaTasbihPageState();
}

class _FatimaTasbihPageState extends State<FatimaTasbihPage> {
  static const phrases = <Map<String, Object>>[
    {'title': 'التكبير', 'text': 'اللَّهُ أَكْبَرُ', 'target': 34},
    {'title': 'التحميد', 'text': 'الْحَمْدُ لِلَّهِ', 'target': 33},
    {'title': 'التسبيح', 'text': 'سُبْحَانَ اللَّهِ', 'target': 33},
  ];

  int stage = 0;
  int count = 0;
  final List<int> counts = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      stage = (prefs.getInt('fatima_tasbih_stage') ?? 0).clamp(0, 2);
      for (var i = 0; i < counts.length; i++) {
        counts[i] = prefs.getInt('fatima_tasbih_$i') ?? 0;
      }
      count = counts[stage];
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fatima_tasbih_stage', stage);
    for (var i = 0; i < counts.length; i++) {
      await prefs.setInt('fatima_tasbih_$i', counts[i]);
    }
  }

  void _nextStage() {
    setState(() {
      stage = (stage + 1) % phrases.length;
      count = counts[stage];
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final phrase = phrases[stage];
    final target = phrase['target'] as int;
    final allDone = counts[0] >= 34 && counts[1] >= 33 && counts[2] >= 33;
    return Scaffold(
      appBar: AppBar(title: const Text('تسبيح الزهراء عليها السلام')),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('التسبيح المشهور بعد الصلاة', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.6)),
            const SizedBox(height: 18),
            Row(
              children: List.generate(phrases.length, (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: i == stage ? const Color(0xFF17483A) : panelGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: i == stage ? accentGold : Colors.white12),
                    ),
                    child: Column(children: [
                      Text(phrases[i]['title'] as String),
                      const SizedBox(height: 4),
                      Text('${counts[i]}/${phrases[i]['target']}',
                        style: const TextStyle(color: accentGold, fontSize: 12)),
                    ]),
                  ),
                ),
              )),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: panelGreen, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accentGold.withValues(alpha: .3))),
              child: Column(children: [
                Text(phrase['title'] as String, style: const TextStyle(color: accentGold, fontSize: 18)),
                const SizedBox(height: 18),
                Text(phrase['text'] as String, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 34, height: 1.8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                Text('$count', style: const TextStyle(fontSize: 60, color: accentGold, fontWeight: FontWeight.bold)),
                Text('من $target', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 14),
                LinearProgressIndicator(value: (count / target).clamp(0.0, 1.0),
                  minHeight: 7, borderRadius: BorderRadius.circular(8),
                  backgroundColor: Colors.white12, color: accentGold),
              ]),
            ),
            const Spacer(),
            SizedBox(height: 58, child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  if (count < target) count++;
                  counts[stage] = count;
                });
                _save();
              },
              icon: const Icon(Icons.touch_app),
              label: const Text('تسبيح', style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(backgroundColor: accentGold, foregroundColor: deepGreen),
            )),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _nextStage,
              icon: const Icon(Icons.arrow_back),
              label: Text(stage == 2 ? 'العودة إلى التكبير' : 'الذكر التالي'),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() { counts[stage] = 0; count = 0; });
                _save();
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('تصفير الذكر الحالي'),
            ),
            if (allDone)
              const Text('أكملت الأذكار الثلاثة. تقبّل الله طاعتك.',
                textAlign: TextAlign.center, style: TextStyle(color: accentGold)),
          ],
        ),
      ),
    );
  }
}

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int count = 0;
  int target = 100;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      count = prefs.getInt('tasbih_count') ?? 0;
      target = prefs.getInt('tasbih_target') ?? 100;
      if (![33, 100, 1000].contains(target)) target = 100;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', count);
    await prefs.setInt('tasbih_target', target);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('المسبحة الإلكترونية')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 20),
      const Icon(Icons.circle_outlined, color: accentGold, size: 42),
      const SizedBox(height: 12),
      const Text('سُبْحَانَ اللَّهِ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Text(count.toString(), style: const TextStyle(fontSize: 64, color: accentGold, fontWeight: FontWeight.bold)),
      Text('الهدف: ' + target.toString(), style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      LinearProgressIndicator(value: (count / target).clamp(0.0, 1.0), minHeight: 7,
        borderRadius: BorderRadius.circular(10), backgroundColor: Colors.white12, color: accentGold),
      const Spacer(),
      SizedBox(width: 190, height: 190, child: FilledButton(
        onPressed: () { setState(() => count++); _saveProgress(); },
        style: FilledButton.styleFrom(backgroundColor: panelGreen, foregroundColor: accentGold,
          shape: const CircleBorder(side: BorderSide(color: accentGold, width: 2))),
        child: const Text('تسبيح', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlinedButton.icon(onPressed: () { setState(() => count = 0); _saveProgress(); },
          icon: const Icon(Icons.restart_alt), label: const Text('تصفير العدّاد')),
        const SizedBox(width: 12),
        DropdownButton<int>(value: target, dropdownColor: panelGreen,
          items: const [DropdownMenuItem(value: 33, child: Text('33')), DropdownMenuItem(value: 100, child: Text('100')), DropdownMenuItem(value: 1000, child: Text('1000'))],
          onChanged: (v) { if (v != null) { setState(() => target = v); _saveProgress(); } }),
      ]),
      const SizedBox(height: 18),
    ])),
  );
}


class ZiyaratPage extends StatelessWidget {
  const ZiyaratPage({super.key});

  static const sourceBook = 'https://lib.rafed.net/view.php?b_id=1731&type=c_fbook';
  static const entries = <Map<String, String>>[
    {'title': 'زيارة الإمام الحسين عليه السلام — مفاتيح الجنان', 'subtitle': 'الزيارات المطلقة والمخصوصة وزيارة وارث وعاشوراء والأربعين', 'url': 'https://lib.rafed.net/view.php?b_id=1731&page=517&type=c_fbook'},
    {'title': 'زيارة وارث', 'subtitle': 'النص ضمن مفاتيح الجنان', 'url': 'https://lib.rafed.net/view.php?b_id=1731&page=524&type=c_fbook'},
    {'title': 'زيارة أبي الفضل العباس عليه السلام', 'subtitle': 'زيارة العباس بن علي عليه السلام في مفاتيح الجنان', 'url': sourceBook},
    {'title': 'زيارة أمين الله', 'subtitle': 'زيارة مروية عن الإمام زين العابدين عليه السلام', 'url': 'https://lib.rafed.net/view.php?b_id=1731&page=443&type=c_fbook'},
    {'title': 'زيارة عاشوراء', 'subtitle': 'الزيارة المشهورة والدعاء بعدها', 'url': sourceBook},
    {'title': 'زيارة الأربعين', 'subtitle': 'زيارة يوم العشرين من صفر', 'url': sourceBook},
    {'title': 'الزيارة الجامعة الكبيرة', 'subtitle': 'زيارة جامعة مروية عن الإمام الهادي عليه السلام', 'url': 'https://alseraj.net/%D9%85%D9%81%D8%A7%D8%AA%D9%8A%D8%AD_%D8%A7%D9%84%D8%AC%D9%86%D8%A7%D9%86/%D8%A7%D9%84%D8%B2%D9%8A%D8%A7%D8%B1%D8%A9-%D8%A7%D9%84%D8%AC%D8%A7%D9%85%D8%B9%D8%A9-%D8%A7%D9%84%D8%AB%D8%A7%D9%86%D9%8A%D8%A9-%D8%A7%D9%84%D8%B2%D9%8A%D8%A7%D8%B1%D8%A9-%D8%A7%D9%84%D8%AC%D8%A7/'},
    {'title': 'زيارة النبي صلى الله عليه وآله', 'subtitle': 'الزيارات وأعمال المدينة المنورة', 'url': sourceBook},
    {'title': 'زيارة السيدة فاطمة الزهراء عليها السلام', 'subtitle': 'نص الزيارة ضمن مفاتيح الجنان', 'url': sourceBook},
    {'title': 'زيارات أمير المؤمنين عليه السلام', 'subtitle': 'ومنها زيارة أمين الله وزيارة يوم الغدير', 'url': sourceBook},
    {'title': 'زيارات أئمة أهل البيت عليهم السلام', 'subtitle': 'زيارات الأئمة في مفاتيح الجنان', 'url': sourceBook},
    {'title': 'زيارة مسلم بن عقيل عليه السلام', 'subtitle': 'ضمن أعمال مسجد الكوفة', 'url': sourceBook},
    {'title': 'زيارة الإمام الرضا عليه السلام', 'subtitle': 'الزيارة وأعمال المشهد الشريف', 'url': sourceBook},
    {'title': 'زيارة الإمامين العسكريين عليهما السلام', 'subtitle': 'زيارات سامراء وأعمال السرداب', 'url': sourceBook},
  ];

  Future<void> _open(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر فتح المصدر. تحقق من اتصال الإنترنت.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الزيارات')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panelGreen,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentGold.withValues(alpha: .35)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book, color: accentGold, size: 32),
              SizedBox(height: 10),
              Text('مكتبة الزيارات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'فهرس لأهم الزيارات مع فتح النصوص من مصادرها. يلزم الإنترنت لقراءة النصوص الخارجية؛ هذه القائمة ليست بعدُ مكتبةً كاملةً تعمل دون اتصال.',
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) => Card(
          color: panelGreen,
          child: ListTile(
            leading: const Icon(Icons.mosque, color: accentGold),
            title: Text(entry['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(entry['subtitle']!, style: const TextStyle(color: Colors.white60, height: 1.4)),
            ),
            trailing: const Icon(Icons.open_in_new, color: accentGold, size: 20),
            onTap: () {
              if (entry['title'] == 'زيارة الأربعين') {
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (_) => const ZiyaratTextPage(),
                ));
              } else {
                _open(context, entry['url']!);
              }
            },
          ),
        )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _open(context, sourceBook),
          icon: const Icon(Icons.library_books),
          label: const Text('فتح كتاب مفاتيح الجنان كاملاً'),
        ),
      ],
    ),
  );
}


class ZiyaratTextPage extends StatefulWidget {
  const ZiyaratTextPage({super.key});

  @override
  State<ZiyaratTextPage> createState() => _ZiyaratTextPageState();
}

class _ZiyaratTextPageState extends State<ZiyaratTextPage> {
  double fontSize = 23;

  static const text = '''
السَّلامُ عَلى وَلِيِّ اللهِ وَحَبِيبِهِ، السَّلامُ عَلى خَلِيلِ اللهِ وَنَجِيبِهِ، السَّلامُ عَلى صَفِيِّ اللهِ وَابْنِ صَفِيِّهِ، السَّلامُ عَلى الحُسَيْنِ المَظْلُومِ الشَّهِيدِ، السَّلامُ عَلى أَسِيرِ الكُرُباتِ وَقَتِيلِ العَبَراتِ.

اللّهُمَّ إِنِّي أَشْهَدُ أَنَّهُ وَلِيُّكَ وَصَفِيُّكَ وَابْنُ صَفِيِّكَ الفائِزُ بِكَرامَتِكَ، أَكْرَمْتَهُ بِالشَّهادَةِ وَحَبَوْتَهُ بِالسَّعادَةِ وَاجْتَبَيْتَهُ بِطِيبِ الوِلادَةِ وَجَعَلْتَهُ سَيِّداً مِنَ السّادَةِ وَقائِداً مِنَ القادَةِ وَذائِداً مِنَ الذّادَةِ وَأَعْطَيْتَهُ مَوارِيثَ الأَنْبِياءِ وَجَعَلْتَهُ حُجَّةً عَلى خَلْقِكَ مِنَ الأَوْصِياءِ، فَأَعْذَرَ فِي الدُّعاءِ وَمَنَحَ النُّصْحَ وَبَذَلَ مُهْجَتَهُ فِيكَ لِيَسْتَنْقِذَ عِبادَكَ مِنَ الجَهالَةِ وَحَيْرَةِ الضَّلالَةِ، وَقَدْ تَوازَرَ عَلَيْهِ مَنْ غَرَّتْهُ الدُّنْيا وَباعَ حَظَّهُ بِالأَرْذَلِ الأَدْنى وَشَرى آخِرَتَهُ بِالثَّمَنِ الأَوْكَسِ وَتَغَطْرَسَ وَتَرَدّى فِي هَواهُ وَأَسْخَطَكَ وَأَسْخَطَ نَبِيَّكَ وَأَطاعَ مِنْ عِبادِكَ أَهْلَ الشِّقاقِ وَالنِّفاقِ وَحَمَلَةَ الأَوْزارِ المُسْتَوْجِبِينَ النّارَ، فَجاهَدَهُمْ فِيكَ صابِراً مُحْتَسِباً حَتّى سُفِكَ فِي طاعَتِكَ دَمُهُ وَاسْتُبِيحَ حَرِيمُهُ.

اللّهُمَّ فَالْعَنْهُمْ لَعْناً وَبِيلاً وَعَذِّبْهُمْ عَذاباً أَلِيماً. السَّلامُ عَلَيْكَ يا ابْنَ رَسُولِ اللهِ، السَّلامُ عَلَيْكَ يا ابْنَ سَيِّدِ الأَوْصِياءِ، أَشْهَدُ أَنَّكَ أَمِينُ اللهِ وَابْنُ أَمِينِهِ، عِشْتَ سَعِيداً وَمَضَيْتَ حَمِيداً وَمُتَّ فَقِيداً مَظْلُوماً شَهِيداً، وَأَشْهَدُ أَنَّ اللهَ مُنْجِزٌ ما وَعَدَكَ وَمُهْلِكٌ مَنْ خَذَلَكَ وَمُعَذِّبٌ مَنْ قَتَلَكَ، وَأَشْهَدُ أَنَّكَ وَفَيْتَ بِعَهْدِ اللهِ وَجاهَدْتَ فِي سَبِيلِهِ حَتّى أَتاكَ اليَقِينُ، فَلَعَنَ اللهُ مَنْ قَتَلَكَ وَلَعَنَ اللهُ مَنْ ظَلَمَكَ وَلَعَنَ اللهُ أُمَّةً سَمِعَتْ بِذلِكَ فَرَضِيَتْ بِهِ.

اللّهُمَّ إِنِّي أُشْهِدُكَ أَنِّي وَلِيٌّ لِمَنْ والاهُ وَعَدُوٌّ لِمَنْ عاداهُ. بِأَبِي أَنْتَ وَأُمِّي يا ابْنَ رَسُولِ اللهِ، أَشْهَدُ أَنَّكَ كُنْتَ نُوراً فِي الأَصْلابِ الشّامِخَةِ وَالأَرْحامِ المُطَهَّرَةِ، لَمْ تُنَجِّسْكَ الجاهِلِيَّةُ بِأَنْجاسِها وَلَمْ تُلْبِسْكَ المُدْلَهِمّاتُ مِنْ ثِيابِها، وَأَشْهَدُ أَنَّكَ مِنْ دَعائِمِ الدِّينِ وَأَرْكانِ المُسْلِمِينَ وَمَعْقِلِ المُؤْمِنِينَ، وَأَشْهَدُ أَنَّكَ الإِمامُ البَرُّ التَّقِيُّ الرَّضِيُّ الزَّكِيُّ الهادِي المَهْدِيُّ، وَأَشْهَدُ أَنَّ الأَئِمَّةَ مِنْ وُلْدِكَ كَلِمَةُ التَّقْوى وَأَعْلامُ الهُدى وَالعُرْوَةُ الوُثْقى وَالحُجَّةُ عَلى أَهْلِ الدُّنْيا.

وَأَشْهَدُ أَنِّي بِكُمْ مُؤْمِنٌ وَبِإِيابِكُمْ مُوقِنٌ بِشَرائِعِ دِينِي وَخَواتِيمِ عَمَلِي، وَقَلْبِي لِقَلْبِكُمْ سِلْمٌ وَأَمْرِي لِأَمْرِكُمْ مُتَّبِعٌ وَنُصْرَتِي لَكُمْ مُعَدَّةٌ حَتّى يَأْذَنَ اللهُ لَكُمْ، فَمَعَكُمْ مَعَكُمْ لا مَعَ عَدُوِّكُمْ، صَلَواتُ اللهِ عَلَيْكُمْ وَعَلى أَرْواحِكُمْ وَأَجْسادِكُمْ وَشاهِدِكُمْ وَغائِبِكُمْ وَظاهِرِكُمْ وَباطِنِكُمْ، آمِينَ رَبَّ العالَمِينَ.
''';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('زيارة الأربعين'),
      actions: [
        IconButton(
          tooltip: 'نسخ النص',
          onPressed: () async {
            await Clipboard.setData(const ClipboardData(text: text));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ نص الزيارة')),
              );
            }
          },
          icon: const Icon(Icons.copy),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: panelGreen,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentGold.withValues(alpha: .3)),
          ),
          child: const Column(
            children: [
              Icon(Icons.menu_book, color: accentGold, size: 30),
              SizedBox(height: 8),
              Text('زيارة الأربعين', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('من الزيارات الواردة في مفاتيح الجنان', style: TextStyle(color: Colors.white60)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('حجم الخط'),
            Expanded(
              child: Slider(
                value: fontSize,
                min: 18,
                max: 34,
                divisions: 8,
                activeColor: accentGold,
                label: fontSize.round().toString(),
                onChanged: (v) => setState(() => fontSize = v),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panelGreen.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(18),
          ),
          child: SelectableText(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, height: 2.05, color: Colors.white),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'المصدر: مفاتيح الجنان، الشيخ عباس القمي، باب زيارة الإمام الحسين عليه السلام وزيارة الأربعين. راجع النص مع النسخة المعتمدة قبل الطباعة أو النشر.',
          style: TextStyle(color: Colors.white54, height: 1.6, fontSize: 12),
        ),
      ],
    ),
  );
}


class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  static const cities = <String, Coordinates>{
    'قلعة سكر': Coordinates(31.8632, 46.0732),
    'الناصرية': Coordinates(31.05799, 46.25726),
    'بغداد': Coordinates(33.3152, 44.3661),
    'النجف': Coordinates(32.0003, 44.3354),
    'كربلاء': Coordinates(32.616, 44.024),
    'البصرة': Coordinates(30.5085, 47.7804),
  };

  String city = 'قلعة سكر';

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_city');
    if (!mounted) return;
    if (saved != null && cities.containsKey(saved)) setState(() => city = saved);
  }

  Future<void> _saveCity(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', value);
  }

  String formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final params = CalculationMethodParameters.jafari();
    final prayerTimes = PrayerTimes(
      coordinates: cities[city]!,
      date: DateTime.now(),
      calculationParameters: params,
    );
    final items = <Map<String, Object>>[
      {'name': 'الفجر', 'time': prayerTimes.fajr, 'icon': Icons.wb_twilight},
      {'name': 'الشروق', 'time': prayerTimes.sunrise, 'icon': Icons.wb_sunny_outlined},
      {'name': 'الظهر', 'time': prayerTimes.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'العصر', 'time': prayerTimes.asr, 'icon': Icons.sunny},
      {'name': 'المغرب', 'time': prayerTimes.maghrib, 'icon': Icons.wb_twilight},
      {'name': 'العشاء', 'time': prayerTimes.isha, 'icon': Icons.nights_stay},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('مواقيت الصلاة')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF17483A), Color(0xFF0D2B24)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accentGold.withValues(alpha: .35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time, color: accentGold, size: 32),
                const SizedBox(height: 10),
                const Text('مواقيت اليوم', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: city,
                  dropdownColor: panelGreen,
                  decoration: const InputDecoration(
                    labelText: 'المدينة',
                    border: OutlineInputBorder(),
                  ),
                  items: cities.keys.map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) { setState(() => city = value); _saveCity(value); }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Card(
            color: panelGreen,
            child: ListTile(
              leading: Icon(item['icon'] as IconData, color: accentGold),
              title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text(
                formatTime(item['time'] as DateTime),
                style: const TextStyle(color: accentGold, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          )),
          const SizedBox(height: 10),
          const Text(
            'طريقة الحساب: الجعفري (تقريب فلكي). قد تختلف الأوقات عن الجداول المحلية أو توقيت الإمساك والأذان المعتمد؛ راجع المصدر الديني المحلي واضبط المدينة الصحيحة. هذه النسخة تعرض الأوقات فقط ولا ترسل أذاناً أو إشعارات بعد.',
            style: TextStyle(color: Colors.white54, height: 1.6, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  String city = 'قلعة سكر';

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_city');
    if (!mounted) return;
    if (saved != null && _PrayerTimesPageState.cities.containsKey(saved)) {
      setState(() => city = saved);
    }
  }

  Future<void> _saveCity(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', value);
  }

  double bearing(Coordinates coordinates) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;
    final lat1 = coordinates.latitude * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;
    final deltaLon = (kaabaLon - coordinates.longitude) * math.pi / 180;
    final y = math.sin(deltaLon);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(deltaLon);
    final degrees = math.atan2(y, x) * 180 / math.pi;
    return (degrees + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    final angle = bearing(_PrayerTimesPageState.cities[city]!);
    return Scaffold(
      appBar: AppBar(title: const Text('اتجاه القبلة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: panelGreen,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accentGold.withValues(alpha: .3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.explore, color: accentGold, size: 34),
                const SizedBox(height: 10),
                const Text('اتجاه الكعبة المشرفة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: city,
                  dropdownColor: panelGreen,
                  decoration: const InputDecoration(labelText: 'المدينة', border: OutlineInputBorder()),
                  items: _PrayerTimesPageState.cities.keys.map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => city = value);
                      _saveCity(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentGold, width: 2),
                      color: panelGreen.withValues(alpha: .55),
                    ),
                  ),
                  const Positioned(top: 17, child: Text('شمال', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                  StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      final heading = snapshot.data?.heading;
                      final rotation = heading == null ? angle : angle - heading;
                      return Transform.rotate(
                        angle: rotation * math.pi / 180,
                        child: const Icon(Icons.navigation, color: accentGold, size: 92),
                      );
                    },
                  ),
                  const Positioned(bottom: 18, child: Text('جنوب', style: TextStyle(color: Colors.white54))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${angle.toStringAsFixed(1)}° من الشمال باتجاه عقارب الساعة',
              textAlign: TextAlign.center,
              style: const TextStyle(color: accentGold, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'يتبع السهم حساس البوصلة في الهاتف إذا كان متاحاً. أبعد الهاتف عن المغناطيس والمعادن وحرّكه على شكل رقم 8 لمعايرة الحساس. إذا لم يظهر اتجاه الحساس، فسيعرض التطبيق الاتجاه المحسوب من الشمال فقط. اختر مدينتك الصحيحة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.7, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


class IslamicLibraryPage extends StatelessWidget {
  const IslamicLibraryPage({super.key});

  static const resources = <Map<String, String>>[
    {'title': 'نص القرآن الكريم', 'description': 'مصدر نص المصحف بالرسم العثماني وشروط النسخ والإسناد.', 'url': 'https://tanzil.net/docs/Text_License', 'source': 'مشروع تنزيل Tanzil'},
    {'title': 'مفاتيح الجنان', 'description': 'نسخة رقمية من كتاب الشيخ عباس القمي للأدعية والزيارات.', 'url': 'https://lib.rafed.net/view.php?b_id=1731&type=c_fbook', 'source': 'مكتبة رافد'},
    {'title': 'زيارة وارث', 'description': 'نص الزيارة مع ترقيم الفقرات للمراجعة والمقابلة.', 'url': 'https://supplications.al-islam.org/ziaraat/ziarat-warith.php?m=print&t=ar_en', 'source': 'Al-Islam.org'},
    {'title': 'دعاء كميل', 'description': 'النص الكامل للدعاء مع معلومات المصدر.', 'url': 'https://al-islam.org/it/commentary-kumayl-supplication-husayn-ansariyan/complete-text-dua-kumayl-arabic-trasliteration-and', 'source': 'Al-Islam.org'},
  ];

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح المصدر')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('المكتبة الإسلامية')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('مصادر للمراجعة والتحقق', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('هذه روابط لمصادر خارجية وليست كتباً مخزونة داخل التطبيق. النصوص الدينية التي سنضيفها دون إنترنت يجب أن تُراجع وتُقابل مع مصدر موثوق.',
          style: TextStyle(color: Colors.white60, height: 1.6)),
        const SizedBox(height: 12),
        ...resources.map((item) => Card(
          color: panelGreen,
          child: ListTile(
            leading: const Icon(Icons.menu_book, color: accentGold),
            title: Text(item['title']!),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(item['description']! + '\nالمصدر: ' + item['source']!, style: const TextStyle(height: 1.5)),
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.open_in_new, color: accentGold),
            onTap: () => _open(context, item['url']!),
          ),
        )),
      ],
    ),
  );
}

class FiqhSourcesPage extends StatelessWidget {
  const FiqhSourcesPage({super.key});

  static const sources = <Map<String, String>>[
    {'title': 'الموقع الرسمي لمكتب السيد علي الخامنئي', 'description': 'للوصول إلى الاستفتاءات والأحكام المنشورة رسمياً.', 'url': 'https://www.leader.ir/ar'},
    {'title': 'مكتب السيد علي السيستاني', 'description': 'مصدر إضافي للمسائل الشرعية والفتاوى المنشورة.', 'url': 'https://www.sistani.org/arabic/'},
  ];

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الموقع')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('المسائل الشرعية')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('ارجع إلى فتوى مرجع تقليدك في الحكم العملي، فقد تختلف الفتاوى بين المراجع.',
          style: TextStyle(color: accentGold, height: 1.7)),
        const SizedBox(height: 12),
        ...sources.map((item) => Card(
          color: panelGreen,
          child: ListTile(
            leading: const Icon(Icons.verified_user_outlined, color: accentGold),
            title: Text(item['title']!),
            subtitle: Text(item['description']!),
            trailing: const Icon(Icons.open_in_new, color: accentGold),
            onTap: () => _open(context, item['url']!),
          ),
        )),
      ],
    ),
  );
}


class HijriCalendarPage extends StatelessWidget {
  const HijriCalendarPage({super.key});

  // Tabular Islamic calendar approximation; actual month starts can differ by local moon sighting.
  static DateTime _toHijri(DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jd = day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) - (y ~/ 100) + (y ~/ 400) - 32045;
    final l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    final ll = l - 10631 * n + 354;
    final j = ((10985 - ll) ~/ 5316) * ((50 * ll) ~/ 17719) + (ll ~/ 5670) * ((43 * ll) ~/ 15238);
    final ll2 = ll - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    final hijriMonth = (24 * ll2) ~/ 709;
    final hijriDay = ll2 - (709 * hijriMonth) ~/ 24;
    final hijriYear = 30 * n + j - 30;
    return DateTime(hijriYear, hijriMonth, hijriDay);
  }

  static const months = [
    'محرم الحرام', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان المبارك', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];
  static const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijri = _toHijri(now);
    final monthName = hijri.month >= 1 && hijri.month <= 12 ? months[hijri.month - 1] : 'غير معروف';
    final weekday = weekdays[now.weekday - 1];
    return Scaffold(
      appBar: AppBar(title: const Text('التقويم الهجري')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [Color(0xFF17483A), Color(0xFF0D2B24)]),
              border: Border.all(color: accentGold.withValues(alpha: .4)),
            ),
            child: Column(children: [
              const Icon(Icons.calendar_month, color: accentGold, size: 42),
              const SizedBox(height: 16),
              const Text('التاريخ الهجري التقريبي', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Text('${hijri.day} $monthName ${hijri.year} هـ',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: accentGold)),
              const SizedBox(height: 8),
              Text('$weekday — ${now.day}/${now.month}/${now.year} م',
                style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 18),
          const Card(
            color: panelGreen,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'تنبيه: هذا تحويل حسابي تقريبي وليس تقويماً شرعياً معتمداً لبداية الأشهر. قد يختلف التاريخ يوماً أو أكثر بحسب ثبوت الهلال وإعلان الجهة الدينية المعتمدة في بلدك. للمناسبات والأحكام الشرعية اعتمد الإعلان المحلي الموثوق.',
                style: TextStyle(height: 1.8, color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://www.leader.ir/ar'), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new),
            label: const Text('متابعة الإعلانات الشرعية من الموقع الرسمي'),
          ),
        ],
      ),
    );
  }
}
