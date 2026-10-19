import 'package:adhan_dart/adhan_dart.dart';

/// A single prayer-related time shown in the daily schedule.
class PrayerEntry {
  const PrayerEntry({
    required this.name,
    required this.time,
    this.isPrayer = true,
  });

  final String name;
  final DateTime time;
  final bool isPrayer;
}

/// Ja'fari daily prayer times and the rules for selecting the next prayer.
class PrayerSchedule {
  const PrayerSchedule._({
    required this.coordinates,
    required this.date,
    required this.entries,
  });

  final Coordinates coordinates;
  final DateTime date;
  final List<PrayerEntry> entries;

  factory PrayerSchedule.forDate({
    required Coordinates coordinates,
    required DateTime date,
  }) {
    final times = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: CalculationMethodParameters.jafari(),
    );

    return PrayerSchedule._(
      coordinates: coordinates,
      date: date,
      entries: List.unmodifiable([
        PrayerEntry(name: 'الفجر', time: times.fajr),
        PrayerEntry(name: 'الشروق', time: times.sunrise, isPrayer: false),
        PrayerEntry(name: 'الظهر', time: times.dhuhr),
        PrayerEntry(name: 'العصر', time: times.asr),
        PrayerEntry(name: 'المغرب', time: times.maghrib),
        PrayerEntry(name: 'العشاء', time: times.isha),
      ]),
    );
  }

  /// Returns the next prayer, skipping sunrise and rolling over to tomorrow's
  /// Fajr when today's prayer times have all passed.
  PrayerEntry nextPrayer({required DateTime now}) {
    for (final entry in entries) {
      if (entry.isPrayer && entry.time.isAfter(now)) return entry;
    }

    final tomorrow = DateTime(date.year, date.month, date.day + 1);
    final nextDay = PrayerSchedule.forDate(
      coordinates: coordinates,
      date: tomorrow,
    );
    return nextDay.entries.firstWhere((entry) => entry.name == 'الفجر');
  }
}
