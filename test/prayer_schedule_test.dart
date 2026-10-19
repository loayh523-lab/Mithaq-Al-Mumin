import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithaq_al_mumin/features/prayer_times/domain/prayer_schedule.dart';

void main() {
  group('PrayerSchedule', () {
    final coordinates = Coordinates(31.8632, 46.0732);

    test('contains six daily time entries and marks sunrise as not a prayer', () {
      final schedule = PrayerSchedule.forDate(
        coordinates: coordinates,
        date: DateTime(2026, 10, 20),
      );

      expect(schedule.entries.map((entry) => entry.name), [
        'الفجر',
        'الشروق',
        'الظهر',
        'العصر',
        'المغرب',
        'العشاء',
      ]);
      expect(schedule.entries.where((entry) => entry.isPrayer), hasLength(5));
      expect(schedule.entries[1].isPrayer, isFalse);
    });

    test('does not select sunrise as the next prayer', () {
      final schedule = PrayerSchedule.forDate(
        coordinates: coordinates,
        date: DateTime(2026, 10, 20),
      );
      final sunrise = schedule.entries[1].time;
      final next = schedule.nextPrayer(
        now: sunrise.subtract(const Duration(minutes: 1)),
      );

      expect(next.name, isNot('الشروق'));
      expect(next.isPrayer, isTrue);
    });

    test('selects tomorrow Fajr after all of today’s prayer times have passed', () {
      final schedule = PrayerSchedule.forDate(
        coordinates: coordinates,
        date: DateTime(2026, 10, 20),
      );
      final afterIsha = schedule.entries.last.time.add(const Duration(hours: 1));

      final next = schedule.nextPrayer(now: afterIsha);

      expect(next.name, 'الفجر');
      expect(next.time.isAfter(afterIsha), isTrue);
    });
  });
}
