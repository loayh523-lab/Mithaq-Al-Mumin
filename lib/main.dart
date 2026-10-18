import 'package:flutter/material.dart';

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
      ['مواقيت الصلاة', 'الأوقات والأذان', Icons.access_time, 'later'],
      ['الأدعية والأذكار', 'تسبيح واستغفار وصلاة', Icons.volunteer_activism, 'adhkar'],
      ['الزيارات', 'نصوص الزيارات', Icons.mosque, 'later'],
      ['اتجاه القبلة', 'تحديد اتجاه القبلة', Icons.explore, 'later'],
      ['المكتبة الإسلامية', 'كتب ومصادر موثوقة', Icons.local_library, 'later'],
      ['المسبحة الإلكترونية', 'تسبيح مع عدّاد', Icons.circle_outlined, 'tasbih'],
      ['المسائل الشرعية', 'أحكام ومصادرها', Icons.gavel, 'later'],
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('قسم ' + f[0] + ' قيد التطوير')));
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
        const Text('نسخة أولية: القرآن متاح لسور مختارة والمسبحة تعمل دون إنترنت. بقية الخدمات قيد التطوير والتحقق من المصادر.',
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
      ]),
    );
  }
}

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});
  static const surahs = <Surah>[
    Surah('الفاتحة', 1, ['بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ','الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ','الرَّحْمَٰنِ الرَّحِيمِ','مَالِكِ يَوْمِ الدِّينِ','إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ','اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ','صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ']),
    Surah('الإخلاص', 112, ['قُلْ هُوَ اللَّهُ أَحَدٌ','اللَّهُ الصَّمَدُ','لَمْ يَلِدْ وَلَمْ يُولَدْ','وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ']),
    Surah('الفلق', 113, ['قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ','مِن شَرِّ مَا خَلَقَ','وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ','وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ','وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ']),
    Surah('الناس', 114, ['قُلْ أَعُوذُ بِرَبِّ النَّاسِ','مَلِكِ النَّاسِ','إِلَٰهِ النَّاسِ','مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ','الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ','مِنَ الْجِنَّةِ وَالنَّاسِ']),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('القرآن الكريم')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('سور مختارة للقراءة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('بداية قسم القرآن. سيُستكمل فهرس المصحف بعد مراجعة النصوص.', style: TextStyle(color: Colors.white60)),
      const SizedBox(height: 12),
      ...surahs.map((s) => Card(color: panelGreen, child: ListTile(
        leading: CircleAvatar(backgroundColor: deepGreen, child: Text(s.number.toString(), style: const TextStyle(color: accentGold))),
        title: Text('سورة ' + s.name),
        subtitle: Text(s.verses.length.toString() + ' آيات'),
        trailing: const Icon(Icons.chevron_left, color: accentGold),
        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SurahPage(surah: s))),
      ))),
    ]),
  );
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
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: panelGreen, borderRadius: BorderRadius.circular(22), border: Border.all(color: accentGold.withValues(alpha: .25))),
        child: Text(surah.verses.asMap().entries.map((e) => e.value + '  ﴿' + (e.key + 1).toString() + '﴾').join('\n\n'),
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, height: 2.1))),
      const SizedBox(height: 16),
      const Text('هذه نسخة أولية بسور مختارة؛ يجب مراجعة الرسم والوقف قبل اعتماد المصحف الكامل.',
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
                  onTap: () => setState(() { selected = i; count = 0; }),
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
              onPressed: () => setState(() { if (count < target) count++; }),
              icon: const Icon(Icons.touch_app),
              label: const Text('سبّح', style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(backgroundColor: accentGold, foregroundColor: deepGreen),
            )),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => setState(() => count = 0),
              icon: const Icon(Icons.restart_alt), label: const Text('تصفير العدّاد'),
            ),
            const SizedBox(height: 12),
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
        onPressed: () => setState(() => count++),
        style: FilledButton.styleFrom(backgroundColor: panelGreen, foregroundColor: accentGold,
          shape: const CircleBorder(side: BorderSide(color: accentGold, width: 2))),
        child: const Text('تسبيح', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlinedButton.icon(onPressed: () => setState(() => count = 0),
          icon: const Icon(Icons.restart_alt), label: const Text('تصفير العدّاد')),
        const SizedBox(width: 12),
        DropdownButton<int>(value: target, dropdownColor: panelGreen,
          items: const [DropdownMenuItem(value: 33, child: Text('33')), DropdownMenuItem(value: 100, child: Text('100')), DropdownMenuItem(value: 1000, child: Text('1000'))],
          onChanged: (v) { if (v != null) setState(() => target = v); }),
      ]),
      const SizedBox(height: 18),
    ])),
  );
}
