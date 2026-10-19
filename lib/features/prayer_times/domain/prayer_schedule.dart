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

/// Calculates the Ja'fari daily prayer schedule independently of the UI.
///
/// Keeping calculation and "next prayer" selection here makes the behaviour
/// testable and prevents each screen from implementing its own time rules.
class PrayerSchedule {
  const PrayerSchedule._(this.entries);

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

    return PrayerSchedule._(List.unmodifiable([
      PrayerEntry(name: 'الفجر', time: times.fajr),
      PrayerEntry(name: 'الشروق', time: times.sunrise, isPrayer: false),
      PrayerEntry(name: 'الظهر', time: times.dhuhr),
      PrayerEntry(name: 'العصر', time: times.asr),
      PrayerEntry(name: 'المغرب', time: times.maghrib),
      PrayerEntry(name: 'العشاء', time: times.isha),
    ]));
  }

  /// Returns the next actual prayer, never sunrise.
  ///
  /// After the final prayer of the day, Fajr is returned as the next day's
  /// upcoming prayer. Callers should calculate a fresh schedule after midnight.
  PrayerEntry nextPrayer({required DateTime now}) {
    for (final entry in entries) {
      if (entry.isPrayer && entry.time.isAfter(now)) return entry;
    }
    return entries.firstWhere((entry) => entry.name == 'الفجر');
  }
}
