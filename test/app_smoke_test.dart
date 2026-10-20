import 'package:flutter_test/flutter_test.dart';
import 'package:mithaq_al_mumin/main.dart';

void main() {
  testWidgets('home screen shows the app name and main sections', (tester) async {
    await tester.pumpWidget(const MeethaqApp());

    expect(find.text('ميثاق المؤمن'), findsOneWidget);
    expect(find.text('ابدأ يومك'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsWidgets);
  });

  testWidgets('tasbeeh counter increments and resets', (tester) async {
    await tester.pumpWidget(const MeethaqApp());

    await tester.tap(find.text('التسبيح').last);
    await tester.pumpAndSettle();

    expect(find.text('0'), findsNothing);
    expect(find.text('اضغط للعدّ'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('زيادة التسبيح'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('تصفير العدّاد'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });
}
