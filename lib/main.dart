import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrayerNotificationService.initialize();
  runApp(const MithaqApp());
}

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String homeCity = 'قلعة سكر';
  Coordinates homeCoordinates = const Coordinates(31.8632, 46.0732);
  Timer? _clockTimer;

  static const homeCities = <String, Coordinates>{
    'قلعة سكر': Coordinates(31.8632, 46.0732),
    'الناصرية': Coordinates(31.05799, 46.25726),
    'بغداد': Coordinates(33.3152, 44.3661),
    'النجف': Coordinates(32.0003, 44.3354),
    'كربلاء': Coordinates(32.616, 44.024),
    'البصرة': Coordinates(30.5085, 47.7804),
  };

  @override
  void initState() {
    super.initState();
    _loadHomeCity();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHomeCity() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_city');
    final lat = prefs.getDouble('prayer_latitude');
    final lon = prefs.getDouble('prayer_longitude');
    if (!mounted) return;
    if (saved == 'موقعي الحالي' && lat != null && lon != null) {
      setState(() {
        homeCity = 'موقعي الحالي';
        homeCoordinates = Coordinates(lat, lon);
      });
    } else if (saved != null && homeCities.containsKey(saved)) {
      setState(() {
        homeCity = saved;
        homeCoordinates = homeCities[saved]!;
      });
    }
  }

  String _homeTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '$hour:${local.minute.toString().padLeft(2, '0')} ${local.hour >= 12 ? 'م' : 'ص'}';
  }
  void open(Widget page) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));

  Widget glass(Widget child, {EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: panelGreen.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: accentGold.withValues(alpha: .24)),
    ),
    child: child,
  );

  Widget home() {
    final now = DateTime.now();
    final calculated = PrayerTimes(
      coordinates: homeCoordinates,
      date: now,
      calculationParameters: CalculationMethodParameters.jafari(),
    );
    final prayerRows = <List<Object>>[
      ['الفجر', calculated.fajr, Icons.wb_twilight],
      ['الشروق', calculated.sunrise, Icons.wb_sunny_outlined],
      ['الظهر', calculated.dhuhr, Icons.wb_sunny],
      ['العصر', calculated.asr, Icons.sunny],
      ['المغرب', calculated.maghrib, Icons.nights_stay_outlined],
      ['العشاء', calculated.isha, Icons.nights_stay],
    ];
    final upcoming = prayerRows
        .where((row) => row[0] != 'الشروق' && (row[1] as DateTime).isAfter(now))
        .toList();
    final nextPrayer = upcoming.isNotEmpty ? upcoming.first : prayerRows.first;
    final prayers = prayerRows;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      glass(Row(children: [
        SizedBox(width: 54, height: 54, child: SvgPicture.asset('assets/logo.svg')),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ميثاق المؤمن', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Text('رفيقك في العبادة والمعرفة', style: TextStyle(color: accentGold, fontSize: 12)),
        ])),
        IconButton(tooltip: 'إعدادات تنبيهات الصلاة', onPressed: () => open(const PrayerAlertsPage()), icon: const Icon(Icons.notifications_none_rounded, color: accentGold)),
      ])),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.location_on_outlined, color: accentGold, size: 17),
        const SizedBox(width: 4),
        Expanded(child: InkWell(
          onTap: () => open(const PrayerTimesPage()),
          child: Text('$homeCity، تغيير المدينة', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        )),
        const Icon(Icons.calendar_month_outlined, color: accentGold, size: 17),
        const SizedBox(width: 5),
        Text('${now.day}/${now.month}/${now.year} م', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
      const SizedBox(height: 20),
      glass(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.access_time_rounded, color: accentGold),
          SizedBox(width: 8),
          Text('الصلاة القادمة', style: TextStyle(color: Colors.white70)),
          Spacer(),
          Icon(Icons.mosque_outlined, color: accentGold),
        ]),
        const SizedBox(height: 12),
        Text('صلاة ${nextPrayer[0]} — ${_homeTime(nextPrayer[1] as DateTime)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text('المواقيت المحسوبة لمدينة $homeCity', style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 15),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () => open(const PrayerTimesPage()),
          style: FilledButton.styleFrom(backgroundColor: accentGold, foregroundColor: deepGreen),
          child: const Text('عرض مواقيت الصلاة'),
        )),
      ]), padding: const EdgeInsets.all(20)),
      const SizedBox(height: 20),
      const Text('مواقيت الصلاة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      SizedBox(height: 99, child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: prayers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, i) => Container(
          width: 90, padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: prayers[i][0] == nextPrayer[0] ? const Color(0xFF17483A) : panelGreen,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: prayers[i][0] == nextPrayer[0] ? accentGold.withValues(alpha: .6) : Colors.white10),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(prayers[i][2] as IconData, color: accentGold, size: 20),
            const SizedBox(height: 5),
            Text(prayers[i][0] as String, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 3),
            Text(_homeTime(prayers[i][1] as DateTime), style: const TextStyle(color: accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      )),
      const SizedBox(height: 22),
      const Text('عبادتك اليومية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: () => open(const AdhkarPage()),
          child: glass(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.auto_awesome_rounded, color: accentGold, size: 28),
            SizedBox(height: 12),
            Text('الأدعية والزيارات', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('أذكار وأدعية يومية', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
        )),
        const SizedBox(width: 10),
        Expanded(child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: () => open(const FatimaTasbihPage()),
          child: glass(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.fingerprint_rounded, color: accentGold, size: 28),
            SizedBox(height: 12),
            Text('تسبيح الزهراء (ع)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('34 تكبيراً و66 ذكراً', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
        )),
      ]),
      const SizedBox(height: 14),
      InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () => setState(() => tab = 1),
        child: glass(const Row(children: [
          Icon(Icons.menu_book_rounded, color: accentGold, size: 29),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('القرآن الكريم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('اقرأ وتدبّر آيات الله', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
          Icon(Icons.chevron_left, color: accentGold),
        ])),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[home(), const QuranPage(), const FatimaTasbihPage(), const AdhkarPage(), const QiblaPage(), const ServicesHubPage()];
    const titles = ['الرئيسية', 'القرآن الكريم', 'تسبيح الزهراء عليها السلام', 'الأدعية والأذكار', 'اتجاه القبلة', 'الخدمات'];
    return Scaffold(
      appBar: tab == 0 ? null : AppBar(title: Text(titles[tab])),
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF041610),
        indicatorColor: accentGold.withValues(alpha: .18),
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: accentGold), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: accentGold), label: 'القرآن'),
          NavigationDestination(icon: Icon(Icons.fingerprint), selectedIcon: Icon(Icons.fingerprint, color: accentGold), label: 'التسبيح'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism, color: accentGold), label: 'الأدعية'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore, color: accentGold), label: 'القبلة'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view_rounded, color: accentGold), label: 'الخدمات'),
        ],
      ),
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

  Widget ornamentLine() => Row(
    children: [
      const Expanded(child: Divider(color: accentGold, thickness: .7)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(Icons.auto_awesome, color: accentGold.withValues(alpha: .8), size: 17),
      ),
      const Expanded(child: Divider(color: accentGold, thickness: .7)),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('سورة ${surah.name}'),
      centerTitle: true,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF17483A), Color(0xFF0B2921)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentGold.withValues(alpha: .7), width: 1.2),
          ),
          child: Column(
            children: [
              ornamentLine(),
              const SizedBox(height: 10),
              Text(
                'سُورَةُ ${surah.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: accentGold,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'عدد الآيات: ${surah.verses.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              ornamentLine(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (surah.number != 1 && surah.number != 9)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: panelGreen.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentGold.withValues(alpha: .18)),
            ),
            child: const Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: accentGold,
                fontSize: 27,
                height: 2,
                fontFamily: 'serif',
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0B2A22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentGold.withValues(alpha: .35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < surah.verses.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '۞',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: accentGold.withValues(alpha: .8), fontSize: 17),
                    ),
                  ),
                SelectableText(
                  '${surah.verses[i]} ﴿${i + 1}﴾',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 26,
                    height: 2.15,
                    fontFamily: 'serif',
                    color: Color(0xFFF8F0DC),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'النص العثماني من مشروع تنزيل Tanzil. الزخرفة لتنسيق العرض فقط، ويُرجى مراجعة النص مع مصحف موثوق.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6),
        ),
      ],
    ),
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
    {'title': 'ذكر يونُس عليه السلام', 'text': 'لا إله إلا أنت سبحانك إني كنت من الظالمين', 'target': 100},
    {'title': 'الحوقلة', 'text': 'لا حول ولا قوة إلا بالله العلي العظيم', 'target': 100},
    {'title': 'دعاء الفرج', 'text': 'اللهم كن لوليك الحجة بن الحسن صلواتك عليه وعلى آبائه', 'target': 100},
    {'title': 'التسبيح بعد الصلاة', 'text': 'سبحان الله والحمد لله ولا إله إلا الله والله أكبر', 'target': 30},
    {'title': 'طلب المغفرة', 'text': 'أستغفر الله الذي لا إله إلا هو الحي القيوم ذو الجلال والإكرام وأتوب إليه', 'target': 70},
    {'title': 'الصلاة على النبي وآله', 'text': 'اللهم صل على محمد وآل محمد وعجل فرجهم', 'target': 100},
    {'title': 'دعاء الحفظ', 'text': 'بسم الله الرحمن الرحيم، لا حول ولا قوة إلا بالله العلي العظيم', 'target': 100},
  ];
  int selected = 0;
  int count = 0;
  late final List<int> savedCounts = List<int>.filled(adhkar.length, 0);

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
            SizedBox(
              height: 220,
              child: ListView.builder(
                itemCount: adhkar.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Card(
                    color: selected == i ? const Color(0xFF17483A) : panelGreen,
                    child: ListTile(
                      dense: true,
                      title: Text(adhkar[i]['title'] as String),
                      trailing: selected == i ? const Icon(Icons.check_circle, color: accentGold) : null,
                      onTap: () { setState(() { selected = i; count = savedCounts[i]; }); _saveProgress(); },
                    ),
                  ),
                ),
              ),
            ),
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
  Coordinates selectedCoordinates = cities['قلعة سكر']!;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_city');
    final lat = prefs.getDouble('prayer_latitude');
    final lon = prefs.getDouble('prayer_longitude');
    if (!mounted) return;
    if (saved == 'موقعي الحالي' && lat != null && lon != null) {
      setState(() {
        city = 'موقعي الحالي';
        selectedCoordinates = Coordinates(lat, lon);
      });
    } else if (saved != null && cities.containsKey(saved)) {
      setState(() {
        city = saved;
        selectedCoordinates = cities[saved]!;
      });
    }
  }

  Future<void> _saveCity(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', value);
    if (!mounted) return;
    setState(() {
      city = value;
      selectedCoordinates = cities[value]!;
    });
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
      coordinates: selectedCoordinates,
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
                  initialValue: city,
                  dropdownColor: panelGreen,
                  decoration: const InputDecoration(
                    labelText: 'المدينة',
                    border: OutlineInputBorder(),
                  ),
                  items: [...(city == 'موقعي الحالي' ? <String>['موقعي الحالي'] : <String>[]), ...cities.keys].map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) { _saveCity(value); }
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
                  initialValue: city,
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

class ServicesHubPage extends StatelessWidget {
  const ServicesHubPage({super.key});
  void _open(BuildContext context, Widget page, String title) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: Text(title)), body: page))));
  }
  @override
  Widget build(BuildContext context) {
    final items = <_ServiceItem>[
      _ServiceItem('مواقيت الصلاة', 'اختيار المدينة ومراجعة الأوقات', Icons.schedule_rounded, () => _open(context, const PrayerTimesPage(), 'مواقيت الصلاة')),
      _ServiceItem('اتجاه القبلة', 'بوصلة لتحديد اتجاه الكعبة', Icons.explore_rounded, () => _open(context, const QiblaPage(), 'اتجاه القبلة')),
      _ServiceItem('متابعة الختمة', 'احفظ تقدمك بقراءة القرآن', Icons.menu_book_rounded, () => _open(context, const KhatmaTrackerPage(), 'متابعة الختمة')),
      _ServiceItem('عداد الركعات', 'سجّل الركعات التي أنجزتها', Icons.countertops_rounded, () => _open(context, const RakatsTrackerPage(), 'عداد الركعات')),
      _ServiceItem('التقويم الهجري', 'مع تنبيه اختلاف التقويم', Icons.calendar_month_rounded, () => _open(context, const HijriInfoPage(), 'التقويم الهجري')),
      _ServiceItem('دليل المناسبات', 'رمضان والأربعين والحج والزيارة', Icons.event_available_rounded, () => _open(context, const OccasionsPage(), 'دليل المناسبات')),
      _ServiceItem('مكتبة الأدعية', 'أدعية مختارة مع نصوص للقراءة', Icons.volunteer_activism_rounded, () => _open(context, const DuaLibraryPage(), 'مكتبة الأدعية')),
      _ServiceItem('مكتبة الزيارات', 'زيارة عاشوراء والزيارة الجامعة المختصرة', Icons.mosque_rounded, () => _open(context, const ZiyaratLibraryPage(), 'مكتبة الزيارات')),
      _ServiceItem('تعقيبات الصلاة', 'أذكار وأعمال بعد الصلاة', Icons.spa_rounded, () => _open(context, const PrayerTaqibatPage(), 'تعقيبات الصلاة')),
      _ServiceItem('أدعية الأيام', 'دعاء مناسب لكل يوم من الأسبوع', Icons.today_rounded, () => _open(context, const DailyDuasPage(), 'أدعية الأيام')),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('خدمات ميثاق المؤمن', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: accentGold)),
      const SizedBox(height: 6), const Text('أدواتك اليومية للعبادة والمتابعة', style: TextStyle(color: Colors.white60)), const SizedBox(height: 18),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Material(
          color: panelGreen,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: item.action,
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: accentGold.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)),
                  child: Icon(item.icon, color: accentGold),
                ),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ])),
                const Icon(Icons.chevron_left_rounded, color: accentGold),
              ]),
            ),
          ),
        ),
      )),
      const SizedBox(height: 8), const Text('ملاحظة: مواقيت الصلاة والتاريخ الهجري قد يختلفان حسب التقويم والجهة الدينية المعتمدة؛ راجع المصدر المحلي عند الحاجة.', style: TextStyle(color: Colors.white54, height: 1.5, fontSize: 12)),
    ]);
  }
}
class _ServiceItem {
  final String title, subtitle; final IconData icon; final VoidCallback action;
  const _ServiceItem(this.title, this.subtitle, this.icon, this.action);
}
class RakatsTrackerPage extends StatefulWidget {
  const RakatsTrackerPage({super.key});
  @override State<RakatsTrackerPage> createState() => _RakatsTrackerPageState();
}
class _RakatsTrackerPageState extends State<RakatsTrackerPage> {
  int count = 0;
  String get _key => 'rakat_count_${DateTime.now().toIso8601String().substring(0,10)}';
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); if (mounted) setState(() => count = p.getInt(_key) ?? 0); }
  Future<void> _change(int delta) async { final next = math.max(0, count + delta); final p = await SharedPreferences.getInstance(); await p.setInt(_key, next); if (mounted) setState(() => count = next); }
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.self_improvement_rounded, size: 66, color: accentGold), const SizedBox(height: 16), const Text('عداد الركعات', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), const Text('عداد شخصي للمتابعة فقط، وليس لتحديد صحة العبادة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)), const SizedBox(height: 25),
    Text('$count', style: const TextStyle(fontSize: 58, color: accentGold, fontWeight: FontWeight.bold)),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton.filledTonal(onPressed: () => _change(-1), icon: const Icon(Icons.remove)), const SizedBox(width: 18), IconButton.filled(onPressed: () => _change(1), icon: const Icon(Icons.add))]),
    TextButton(onPressed: () => _change(-count), child: const Text('تصفير عداد اليوم'))
  ])));
}
class KhatmaTrackerPage extends StatefulWidget {
  const KhatmaTrackerPage({super.key});
  @override State<KhatmaTrackerPage> createState() => _KhatmaTrackerPageState();
}
class _KhatmaTrackerPageState extends State<KhatmaTrackerPage> {
  int pages = 0; final int total = 604;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); if (mounted) setState(() => pages = p.getInt('khatma_pages') ?? 0); }
  Future<void> _set(int v) async { final p = await SharedPreferences.getInstance(); final value = v.clamp(0, total); await p.setInt('khatma_pages', value); if (mounted) setState(() => pages = value); }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(22), children: [
    const Icon(Icons.menu_book_rounded, size: 60, color: accentGold), const SizedBox(height: 16), const Text('متابعة ختمة القرآن', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 22),
    LinearProgressIndicator(value: pages / total, minHeight: 10, color: accentGold, backgroundColor: panelGreen), const SizedBox(height: 14),
    Text('$pages من $total صفحة', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)), Text('${(pages / total * 100).round()}٪ مكتمل', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)), const SizedBox(height: 24),
    Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [for (final n in [1, 5, 10, 20]) OutlinedButton(onPressed: () => _set(pages + n), child: Text('+$n صفحات')), OutlinedButton(onPressed: () => _set(0), child: const Text('ختمة جديدة'))]),
    const SizedBox(height: 12), const Text('عدد الصفحات تقديري وفق مصحف شائع من 604 صفحات.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12))
  ]);
}
class HijriInfoPage extends StatelessWidget {
  const HijriInfoPage({super.key});
  @override Widget build(BuildContext context) { final now = DateTime.now(); return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.calendar_month_rounded, size: 64, color: accentGold), const SizedBox(height: 18), const Text('التقويم الهجري', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
    Text('التاريخ الميلادي: ${now.day}/${now.month}/${now.year}', style: const TextStyle(fontSize: 17)), const SizedBox(height: 12),
    const Text('التاريخ الهجري يحتاج تقويماً موثوقاً أو إعلاناً شرعياً وقد يختلف يوماً بين البلدان. سنربطه بمصدر موثوق قبل عرضه كتاريخ معتمد.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, height: 1.7))
  ]))); }
}
class OccasionsPage extends StatelessWidget {
  const OccasionsPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: const [
    Text('دليل المناسبات والزيارات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentGold)), SizedBox(height: 14),
    _OccasionCard(icon: Icons.nightlight_round, title: 'شهر رمضان', body: 'متابعة الصيام والقراءة والدعاء. راجع مواقيت الإمساك والإفطار وفق التقويم المحلي المعتمد.'),
    _OccasionCard(icon: Icons.directions_walk_rounded, title: 'زيارة الأربعين', body: 'تهيّأ للزيارة بالدعاء وقراءة الزيارة المأثورة ومراعاة تعليمات السلامة والخدمات الرسمية على الطريق.'),
    _OccasionCard(icon: Icons.mosque_rounded, title: 'الحج والعمرة', body: 'راجع المناسك والأحكام من مصدر فقهي موثوق قبل السفر، فبعض التفاصيل تختلف باختلاف المرجع.'),
    _OccasionCard(icon: Icons.auto_stories_rounded, title: 'الزيارات والأعمال', body: 'أظهر مصدر كل نص ديني بوضوح عند إضافة النصوص للتطبيق.')
  ]);
}
class _OccasionCard extends StatelessWidget {
  final IconData icon; final String title, body;
  const _OccasionCard({required this.icon, required this.title, required this.body});
  @override Widget build(BuildContext context) => Card(color: panelGreen, margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: accentGold, size: 28), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 6), Text(body, style: const TextStyle(color: Colors.white70, height: 1.5))]))
  ])));
}

class DuaLibraryPage extends StatelessWidget {
  const DuaLibraryPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Text('مكتبة الأدعية', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: accentGold)),
    SizedBox(height: 8), Text('نصوص قصيرة للقراءة؛ تُضاف النصوص الكاملة مع توثيق مصدرها في التحديثات القادمة.', style: TextStyle(color: Colors.white60, height: 1.5)),
    SizedBox(height: 14),
    _TextPrayerCard(title: 'دعاء الفرج', source: 'دعاء متداول لطلب الفرج', body: 'اللهم كن لوليك الحجة بن الحسن، صلواتك عليه وعلى آبائه، في هذه الساعة وفي كل ساعة، ولياً وحافظاً وقائداً وناصراً ودليلاً وعيناً، حتى تسكنه أرضك طوعاً وتمتعه فيها طويلاً.'),
    _TextPrayerCard(title: 'دعاء التوسل', source: 'مقتطف افتتاحي — ليس النص الكامل', body: 'اللهم إني أسألك وأتوجه إليك بنبيك نبي الرحمة محمد صلى الله عليه وآله.'),
    _TextPrayerCard(title: 'دعاء العهد', source: 'مقتطف افتتاحي — ليس النص الكامل', body: 'اللهم رب النور العظيم، ورب الكرسي الرفيع، ورب البحر المسجور...'),
    _TextPrayerCard(title: 'دعاء كميل', source: 'مقتطف افتتاحي — ليس النص الكامل', body: 'اللهم إني أسألك برحمتك التي وسعت كل شيء، وبقوتك التي قهرت بها كل شيء...'),
    _TextPrayerCard(title: 'دعاء الندبة', source: 'مكتبة الأدعية', body: 'يمكن قراءة دعاء الندبة في أوقاته المأثورة؛ ستُضاف النسخة الكاملة بعد مراجعة النص والمصدر.'),
  ]);
}
class ZiyaratLibraryPage extends StatelessWidget {
  const ZiyaratLibraryPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Text('مكتبة الزيارات', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: accentGold)),
    SizedBox(height: 8), Text('نحافظ على نصوص الزيارات كما وردت ولا نكمل النصوص من الذاكرة؛ هذه الصفحة فهرس أولي.', style: TextStyle(color: Colors.white60, height: 1.5)),
    SizedBox(height: 14),
    _TextPrayerCard(title: 'زيارة عاشوراء', source: 'زيارة الإمام الحسين عليه السلام', body: 'السلام عليك يا أبا عبد الله، السلام عليك يا ابن رسول الله، السلام عليك يا ابن أمير المؤمنين وابن سيد الوصيين...'),
    _TextPrayerCard(title: 'زيارة وارث', source: 'النص الكامل بحسب Shia Prayer Times — shiaprayertimes.org/resources/ziyarat/ziyarat-warith', body: '''السَّلامُ عَلَيْكَ يا وارِثَ آدَمَ صَفْوَةِ اللهِ
السَّلامُ عَلَيْكَ يا وارِثَ نُوحٍ نَبِيِّ اللهِ
السَّلامُ عَلَيْكَ يا وارِثَ إِبْراهِيمَ خَلِيلِ اللهِ
السَّلامُ عَلَيْكَ يا وارِثَ مُوسى كَلِيمِ اللهِ
السَّلامُ عَلَيْكَ يا وارِثَ عِيسى رُوحِ اللهِ
السَّلامُ عَلَيْكَ يا وارِثَ مُحَمَّدٍ حَبِيبِ اللهِ
السَّلامُ عَلَيْكَ يا وارِثَ أَمِيرِ الْمُؤْمِنِينَ عَلَيْهِ السَّلامُ
السَّلامُ عَلَيْكَ يا ابْنَ مُحَمَّدٍ الْمُصْطَفَى
السَّلامُ عَلَيْكَ يا ابْنَ عَلِيٍّ الْمُرْتَضَى
السَّلامُ عَلَيْكَ يا ابْنَ فاطِمَةَ الزَّهْراءِ
السَّلامُ عَلَيْكَ يا ابْنَ خَدِيجَةَ الْكُبْرَى
السَّلامُ عَلَيْكَ يا ثارَ اللهِ وَابْنَ ثارِهِ وَالْوِتْرَ الْمَوْتُورَ
أَشْهَدُ أَنَّكَ قَدْ أَقَمْتَ الصَّلاةَ وَآتَيْتَ الزَّكاةَ وَأَمَرْتَ بِالْمَعْرُوفِ وَنَهَيْتَ عَنِ الْمُنْكَرِ وَأَطَعْتَ اللهَ وَرَسُولَهُ حَتّى أَتاكَ الْيَقِينُ
فَلَعَنَ اللهُ أُمَّةً قَتَلَتْكَ وَلَعَنَ اللهُ أُمَّةً ظَلَمَتْكَ وَلَعَنَ اللهُ أُمَّةً سَمِعَتْ بِذلِكَ فَرَضِيَتْ بِهِ
يا مَوْلايَ يا أَبا عَبْدِ اللهِ أَشْهَدُ أَنَّكَ كُنْتَ نُوراً فِي الْأَصْلابِ الشّامِخَةِ وَالْأَرْحامِ الْمُطَهَّرَةِ لَمْ تُنَجِّسْكَ الْجاهِلِيَّةُ بِأَنْجاسِها وَلَمْ تُلْبِسْكَ مِنْ مُدْلَهِمّاتِ ثِيابِها
وَأَشْهَدُ أَنَّكَ مِنْ دَعائِمِ الدِّينِ وَأَرْكانِ الْمُؤْمِنِينَ وَأَشْهَدُ أَنَّكَ الْإِمامُ الْبَرُّ التَّقِيُّ الرَّضِيُّ الزَّكِيُّ الْهادِي الْمَهْدِيُّ
وَأَشْهَدُ أَنَّ الْأَئِمَّةَ مِنْ وُلْدِكَ كَلِمَةُ التَّقْوى وَأَعْلامُ الْهُدى وَالْعُرْوَةُ الْوُثْقى وَالْحُجَّةُ عَلى أَهْلِ الدُّنْيا
وَأُشْهِدُ اللهَ وَمَلائِكَتَهُ وَأَنْبِياءَهُ وَرُسُلَهُ أَنِّي بِكُمْ مُؤْمِنٌ وَبِإِيابِكُمْ مُوقِنٌ بِشَرائِعِ دِينِي وَخَواتِيمِ عَمَلِي وَقَلْبِي لِقَلْبِكُمْ سِلْمٌ وَأَمْرِي لِأَمْرِكُمْ مُتَّبِعٌ
صَلَواتُ اللهِ عَلَيْكُمْ وَعَلى أَرْواحِكُمْ وَعَلى أَجْسادِكُمْ وَعَلى أَجْسامِكُمْ وَعَلى شاهِدِكُمْ وَغائِبِكُمْ وَظاهِرِكُمْ وَباطِنِكُمْ
بِأَبِي أَنْتَ وَأُمِّي يا ابْنَ رَسُولِ اللهِ بِأَبِي أَنْتَ وَأُمِّي يا أَبا عَبْدِ اللهِ لَقَدْ عَظُمَتِ الرَّزِيَّةُ وَجَلَّتِ الْمُصِيبَةُ بِكَ عَلَيْنا وَعَلى جَمِيعِ أَهْلِ السَّماواتِ وَالْأَرْضِ
فَلَعَنَ اللهُ أُمَّةً أَسْرَجَتْ وَأَلْجَمَتْ وَتَهَيَّأَتْ لِقِتالِكَ
يا مَوْلايَ يا أَبا عَبْدِ اللهِ قَصَدْتُ حَرَمَكَ وَأَتَيْتُ إِلى مَشْهَدِكَ أَسْأَلُ اللهَ بِالشَّأْنِ الَّذِي لَكَ عِنْدَهُ وَبِالْمَحَلِّ الَّذِي لَكَ لَدَيْهِ أَنْ يُصَلِّيَ عَلى مُحَمَّدٍ وَآلِ مُحَمَّدٍ وَأَنْ يَجْعَلَنِي مَعَكُمْ فِي الدُّنْيا وَالْآخِرَةِ
السَّلامُ عَلَيْكَ يا ابْنَ رَسُولِ اللهِ
السَّلامُ عَلَيْكَ يا ابْنَ نَبِيِّ اللهِ
السَّلامُ عَلَيْكَ يا ابْنَ أَمِيرِ الْمُؤْمِنِينَ
السَّلامُ عَلَيْكَ يا ابْنَ الْحُسَيْنِ الشَّهِيدِ
السَّلامُ عَلَيْكَ أَيُّهَا الشَّهِيدُ
السَّلامُ عَلَيْكَ أَيُّهَا الْمَظْلُومُ وَابْنُ الْمَظْلُومِ
لَعَنَ اللهُ أُمَّةً قَتَلَتْكَ وَلَعَنَ اللهُ أُمَّةً ظَلَمَتْكَ وَلَعَنَ اللهُ أُمَّةً سَمِعَتْ بِذلِكَ فَرَضِيَتْ بِهِ
السَّلامُ عَلَيْكَ يا وَلِيَّ اللهِ وَابْنَ وَلِيِّهِ لَقَدْ عَظُمَتِ الْمُصِيبَةُ وَجَلَّتِ الرَّزِيَّةُ بِكَ عَلَيْنا وَعَلى جَمِيعِ الْمُسْلِمِينَ
فَلَعَنَ اللهُ أُمَّةً قَتَلَتْكَ وَأَبْرَأُ إِلَى اللهِ وَإِلَيْكَ مِنْهُمْ'''),
    _TextPrayerCard(title: 'زيارة أمين الله', source: 'النص الكامل — Shia Prayer Times: https://shiaprayertimes.org/resources/ziyarat/ziyarat-ameenallah', body: '''بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ
السَّلامُ عَلَيْكَ يا أَمِينَ اللهِ فِي أَرْضِهِ وَحُجَّتَهُ عَلَى عِبادِهِ
السَّلامُ عَلَيْكَ يا أَمِيرَ الْمُؤْمِنِينَ
أَشْهَدُ أَنَّكَ جاهَدْتَ فِي اللهِ حَقَّ جِهادِهِ وَعَمِلْتَ بِكِتابِهِ وَاتَّبَعْتَ سُنَنَ نَبِيِّهِ صَلَّى اللهُ عَلَيْهِ وَآلِهِ حَتَّى دَعاكَ اللهُ إِلَى جِوارِهِ فَقَبَضَكَ إِلَيْهِ بِاخْتِيارِهِ وَأَلْزَمَ أَعْداءَكَ الْحُجَّةَ مَعَ ما لَكَ مِنَ الْحُجَجِ الْبالِغَةِ عَلَى جَمِيعِ خَلْقِهِ
اللَّهُمَّ فَاجْعَلْ نَفْسِي مُطْمَئِنَّةً بِقَدَرِكَ راضِيَةً بِقَضائِكَ مُولَعَةً بِذِكْرِكَ وَدُعائِكَ مُحِبَّةً لِصَفْوَةِ أَوْلِيائِكَ مَحْبُوبَةً فِي أَرْضِكَ وَسَمائِكَ صابِرَةً عَلَى نُزُولِ بَلائِكَ شاكِرَةً لِفَواضِلِ نَعْمائِكَ ذاكِرَةً لِسَوابِغِ آلائِكَ مُشْتاقَةً إِلَى فَرْحَةِ لِقائِكَ مُتَزَوِّدَةً التَّقْوَى لِيَوْمِ جَزائِكَ مُسْتَنَّةً بِسُنَنِ أَوْلِيائِكَ مُفارِقَةً لِأَخْلاقِ أَعْدائِكَ مَشْغُولَةً عَنِ الدُّنْيا بِحَمْدِكَ وَثَنائِكَ
اللَّهُمَّ إِنَّ قُلُوبَ الْمُخْبِتِينَ إِلَيْكَ والِهَةٌ وَسُبُلَ الرَّاغِبِينَ إِلَيْكَ شارِعَةٌ وَأَعْلامَ الْقاصِدِينَ إِلَيْكَ واضِحَةٌ وَأَفْئِدَةَ الْعارِفِينَ مِنْكَ فازِعَةٌ وَأَصْواتَ الدَّاعِينَ إِلَيْكَ صاعِدَةٌ وَأَبْوابَ الْإِجابَةِ لَهُمْ مُفَتَّحَةٌ وَدَعْوَةَ مَنْ ناجاكَ مُسْتَجابَةٌ وَتَوْبَةَ مَنْ أَنابَ إِلَيْكَ مَقْبُولَةٌ وَعَبْرَةَ مَنْ بَكَى مِنْ خَوْفِكَ مَرْحُومَةٌ وَالْإِغاثَةَ لِمَنِ اسْتَغاثَ بِكَ مَوْجُودَةٌ وَالْإِعانَةَ لِمَنِ اسْتَعانَ بِكَ مَبْذُولَةٌ وَعِداتِكَ لِعِبادِكَ مُنْجَزَةٌ وَزَلَلَ مَنِ اسْتَقالَكَ مُقالَةٌ وَأَعْمالَ الْعامِلِينَ لَدَيْكَ مَحْفُوظَةٌ وَأَرْزاقَكَ إِلَى الْخَلائِقِ مِنْ لَدُنْكَ نازِلَةٌ وَعَوائِدَ الْمَزِيدِ إِلَيْهِمْ واصِلَةٌ وَذُنُوبَ الْمُسْتَغْفِرِينَ مَغْفُورَةٌ وَحَوائِجَ خَلْقِكَ عِنْدَكَ مَقْضِيَّةٌ وَجَوائِزَ السَّائِلِينَ عِنْدَكَ مُوَفَّرَةٌ وَعَوائِدَ الْمَزِيدِ مُتَواتِرَةٌ وَمَوائِدَ الْمُسْتَطْعِمِينَ مُعَدَّةٌ وَمَناهِلَ الظِّماءِ مُتْرَعَةٌ
اللَّهُمَّ فَاسْتَجِبْ دُعائِي وَاقْبَلْ ثَنائِي وَاجْمَعْ بَيْنِي وَبَيْنَ أَوْلِيائِي بِحَقِّ مُحَمَّدٍ وَعَلِيٍّ وَفاطِمَةَ وَالْحَسَنِ وَالْحُسَيْنِ إِنَّكَ وَلِيُّ نَعْمائِي وَمُنْتَهَى مُنايَ وَغايَةُ رَجائِي فِي مُنْقَلَبِي وَمَثْوايَ'''),
    _TextPrayerCard(title: 'الزيارة الجامعة الكبيرة', source: 'زيارة جامعة لأئمة أهل البيت عليهم السلام', body: 'السلام عليكم يا أهل بيت النبوة، وموضع الرسالة، ومختلف الملائكة، ومهبط الوحي...'),
    _TextPrayerCard(title: 'زيارة أبي الفضل العباس عليه السلام', source: 'زيارة أبي الفضل العباس عليه السلام', body: 'السلام عليك يا ابن أمير المؤمنين، السلام عليك أيها العبد الصالح المطيع لله ولرسوله ولأمير المؤمنين والحسن والحسين صلوات الله عليهم أجمعين...'),
  ]);
}
class _TextPrayerCard extends StatelessWidget {
  final String title, source, body;
  const _TextPrayerCard({required this.title, required this.source, required this.body});
  @override Widget build(BuildContext context) => Card(color: panelGreen, margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: accentGold, fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4), Text(source, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    const SizedBox(height: 12), SelectableText(body, style: const TextStyle(fontSize: 17, height: 1.9)),
    const SizedBox(height: 8), const Text('المعروض هنا مقتطف؛ لا يُعرض على أنه النص الكامل.', style: TextStyle(color: Colors.white38, fontSize: 11)),
    Align(alignment: Alignment.centerLeft, child: TextButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: '$title\n$source\n\n$body'));
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
      },
      icon: const Icon(Icons.copy_rounded, size: 18),
      label: const Text('نسخ النص'),
    )),
  ])));
}

class PrayerNotificationService {
  PrayerNotificationService._();
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  static const String channelId = 'prayer_times';
  static const String channelName = 'تنبيهات مواقيت الصلاة';

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static Future<void> cancelPrayerAlerts() => plugin.cancelAll();

  static Future<void> schedulePrayerAlerts(String city, Coordinates coordinates, {bool sound = true}) async {
    await cancelPrayerAlerts();
    final now = DateTime.now();
    final names = <String>['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      final times = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: CalculationMethodParameters.jafari());
      final moments = <DateTime?>[times.fajr, times.dhuhr, times.asr, times.maghrib, times.isha];
      for (var i = 0; i < moments.length; i++) {
        final moment = moments[i];
        if (moment == null || !moment.isAfter(now)) continue;
        final when = tz.TZDateTime.from(moment, tz.local);
        await plugin.zonedSchedule(
          dayOffset * 10 + i,
          'حان وقت صلاة ${names[i]}',
          'ميثاق المؤمن • ${city}',
          when,
          NotificationDetails(android: AndroidNotificationDetails(
            channelId, channelName,
            channelDescription: 'تنبيهات مواقيت الصلاة المحسوبة محلياً',
            importance: Importance.max,
            priority: Priority.high,
            playSound: sound,
          )),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}

class PrayerAlertsPage extends StatefulWidget {
  const PrayerAlertsPage({super.key});
  @override State<PrayerAlertsPage> createState() => _PrayerAlertsPageState();
}
class _PrayerAlertsPageState extends State<PrayerAlertsPage> {
  bool enabled = false;
  bool sound = true;
  bool busy = false;
  bool usingLocation = false;
  String message = 'التنبيهات غير مفعّلة';

  Future<void> _useCurrentLocation() async {
    setState(() { busy = true; message = 'جارٍ تحديد الموقع...'; });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => message = 'شغّل خدمة الموقع GPS من إعدادات الهاتف ثم أعد المحاولة');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => message = 'إذن الموقع مرفوض؛ اسمح للتطبيق باستخدام الموقع من إعدادات الهاتف');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('prayer_latitude', position.latitude);
      await prefs.setDouble('prayer_longitude', position.longitude);
      await prefs.setString('selected_city', 'موقعي الحالي');
      if (mounted) setState(() { usingLocation = true; message = 'تم حفظ موقعك؛ فعّل التنبيهات لتُحسب على إحداثياتك'; });
    } catch (_) {
      if (mounted) setState(() => message = 'ما كدرنا نحدد الموقع. تأكد من GPS والإنترنت وحاول مجددًا');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() { busy = true; });
    try {
      if (!value) {
        await PrayerNotificationService.cancelPrayerAlerts();
        if (mounted) setState(() { enabled = false; message = 'تم إيقاف التنبيهات'; });
      } else {
        final allowed = await PrayerNotificationService.requestPermission();
        if (!allowed) {
          if (mounted) setState(() => message = 'فعّل إذن الإشعارات من إعدادات الهاتف ثم أعد المحاولة');
        } else {
          final prefs = await SharedPreferences.getInstance();
          final city = prefs.getString('selected_city') ?? 'قلعة سكر';
          final savedLat = prefs.getDouble('prayer_latitude');
          final savedLon = prefs.getDouble('prayer_longitude');
          final hasGps = city == 'موقعي الحالي' && savedLat != null && savedLon != null;
          final coords = hasGps
              ? Coordinates(savedLat!, savedLon!)
              : (_PrayerTimesPageState.cities[city] ?? const Coordinates(31.8632, 46.0732));
          await PrayerNotificationService.schedulePrayerAlerts(city, coords, sound: sound);
          if (mounted) setState(() { enabled = true; message = 'تم إعداد تنبيهات الصلاة للأيام السبعة القادمة'; });
        }
      }
    } catch (e) {
      if (mounted) setState(() => message = 'تعذر إعداد التنبيهات؛ تحقق من أذونات الهاتف');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Icon(Icons.notifications_active_rounded, size: 62, color: accentGold),
    const SizedBox(height: 14),
    const Text('تنبيهات الصلاة', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('تُحسب الأوقات بالطريقة الجعفرية للمدينة المحفوظة. أعد تفعيل التنبيهات بعد تغيير المدينة أو إذا تغيّر التوقيت.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, height: 1.6)),
    const SizedBox(height: 16),
    OutlinedButton.icon(
      onPressed: busy ? null : _useCurrentLocation,
      icon: const Icon(Icons.my_location_rounded),
      label: Text(busy ? 'جارٍ العمل...' : usingLocation ? 'تم حفظ موقعي' : 'استخدام موقعي الحالي GPS'),
    ),
    const SizedBox(height: 6),
    const Text('يحتاج إذن الموقع وتشغيل GPS. إذا لم تستخدمه، يعتمد التطبيق على المدينة المختارة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.5)),
    const SizedBox(height: 16),
    SwitchListTile(value: sound, onChanged: (v) => setState(() => sound = v), title: const Text('صوت تنبيه'), subtitle: const Text('صوت إشعار النظام؛ ملف الأذان الكامل يحتاج إضافته منفصلاً'), activeColor: accentGold),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: busy ? null : () => _toggle(!enabled), icon: Icon(enabled ? Icons.notifications_off : Icons.notifications_active), label: Text(busy ? 'جارٍ الإعداد...' : enabled ? 'إيقاف التنبيهات' : 'تفعيل تنبيهات الصلاة')),
    const SizedBox(height: 14),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
    const SizedBox(height: 10),
    OutlinedButton(onPressed: () async { await PrayerNotificationService.plugin.show(999, 'تجربة التنبيه', 'إذا ظهر هذا الإشعار فالإذن يعمل على جهازك.', const NotificationDetails(android: AndroidNotificationDetails(PrayerNotificationService.channelId, PrayerNotificationService.channelName, importance: Importance.max, priority: Priority.high))); }, child: const Text('اختبار الإشعار')),
  ]);
}

class PrayerTaqibatPage extends StatelessWidget {
  const PrayerTaqibatPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Text('تعقيبات الصلاة', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: accentGold)),
    SizedBox(height: 8),
    Text('أعمال مشهورة في كتب الأدعية عند الإمامية. ترتيب الاستحباب وبعض التفاصيل قد يختلف؛ اعتمد النص الكامل من مصدر موثوق.', style: TextStyle(color: Colors.white60, height: 1.6)),
    SizedBox(height: 14),
    _TextPrayerCard(title: 'التكبير بعد الصلاة', source: 'ذكر مشهور بعد الصلاة', body: 'الله أكبر، الله أكبر، الله أكبر.'),
    _TextPrayerCard(title: 'تسبيح الزهراء عليها السلام', source: 'التسبيح المعروف بعد الصلاة', body: 'الله أكبر ٣٤ مرة\nالحمد لله ٣٣ مرة\nسبحان الله ٣٣ مرة'),
    _TextPrayerCard(title: 'آية الكرسي', source: 'سورة البقرة، الآية ٢٥٥', body: 'الله لا إله إلا هو الحي القيوم لا تأخذه سنة ولا نوم له ما في السماوات وما في الأرض من ذا الذي يشفع عنده إلا بإذنه يعلم ما بين أيديهم وما خلفهم ولا يحيطون بشيء من علمه إلا بما شاء وسع كرسيه السماوات والأرض ولا يؤوده حفظهما وهو العلي العظيم.'),
    _TextPrayerCard(title: 'سورة الإخلاص', source: 'سورة الإخلاص', body: 'بسم الله الرحمن الرحيم\nقل هو الله أحد، الله الصمد، لم يلد ولم يولد، ولم يكن له كفواً أحد.'),
    _TextPrayerCard(title: 'سورة الفلق', source: 'سورة الفلق', body: 'بسم الله الرحمن الرحيم\nقل أعوذ برب الفلق، من شر ما خلق، ومن شر غاسق إذا وقب، ومن شر النفاثات في العقد، ومن شر حاسد إذا حسد.'),
    _TextPrayerCard(title: 'سورة الناس', source: 'سورة الناس', body: 'بسم الله الرحمن الرحيم\nقل أعوذ برب الناس، ملك الناس، إله الناس، من شر الوسواس الخناس، الذي يوسوس في صدور الناس، من الجنة والناس.'),
  ]);
}

class DailyDuasPage extends StatelessWidget {
  const DailyDuasPage({super.key});
  static const List<Map<String, String>> days = [
    {'name':'الأحد','title':'طلب الرحمة','text':'يا الله ارحمني برحمتك، واغفر لي ولوالدي، واهدني لما تحب وترضى، وثبّت قلبي على طاعتك.'},
    {'name':'الاثنين','title':'طلب التوفيق','text':'اللهم وفّقني للخير، وأعنّي على ذكرك وشكرك وحسن عبادتك، وبارك لي في وقتي وعلمي وعملي.'},
    {'name':'الثلاثاء','title':'طلب الرزق الحلال','text':'اللهم ارزقني رزقاً حلالاً طيباً واسعاً، واصرف عني الحرام، واجعلني من الشاكرين.'},
    {'name':'الأربعاء','title':'طلب العلم','text':'ربّ زدني علماً، وارزقني فهماً نافعاً وعملاً صالحاً، واجعل علمي سبباً للخير وخدمة عبادك.'},
    {'name':'الخميس','title':'طلب المغفرة','text':'أستغفر الله ربي وأتوب إليه، اللهم اغفر لي ما قدّمت وما أخّرت، وأصلح سريرتي وعلانيتي.'},
    {'name':'الجمعة','title':'الصلاة على محمد وآل محمد','text':'اللهم صلّ على محمد وآل محمد، وعجّل فرجهم، واجعلنا من المتمسكين بولايتهم والسائرين على نهجهم.'},
    {'name':'السبت','title':'طلب الثبات','text':'اللهم ثبّتني على الحق، وارزقني حسن العاقبة، واحفظ أهلي وأحبتي، واكتب لنا الخير في الدنيا والآخرة.'},
  ];
  @override Widget build(BuildContext context) {
    final today = DateTime.now().weekday % 7;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('أدعية الأيام', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: accentGold)),
      const SizedBox(height: 8),
      const Text('هذه صياغات دعائية عامة مرتبة للأيام وليست منسوبة إلى رواية أو إمام. للدعاء المأثور نضيف النص مع مصدره المحدد.', style: TextStyle(color: Colors.white60, height: 1.6)),
      const SizedBox(height: 14),
      for (var i = 0; i < days.length; i++)
        Card(color: panelGreen, margin: const EdgeInsets.only(bottom: 11), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('دعاء يوم ${days[i]['name']}', style: const TextStyle(color: accentGold, fontSize: 18, fontWeight: FontWeight.bold))), if (i == today) const Chip(label: Text('اليوم'))]),
          const SizedBox(height: 6), Text(days[i]['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10), Text(days[i]['text']!, style: const TextStyle(fontSize: 17, height: 1.9)),
          Align(alignment: Alignment.centerLeft, child: IconButton(tooltip: 'نسخ الدعاء', onPressed: () => Clipboard.setData(ClipboardData(text: days[i]['text']!)), icon: const Icon(Icons.copy_rounded, color: accentGold))),
        ]))),
    ]);
  }
}
