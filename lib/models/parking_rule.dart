import 'package:flutter/material.dart';

/// Days of the week a parking rule can apply to. Values match the ISO-8601
/// weekday numbering (Monday = 1) used by `DateTime.weekday`, so a rule can
/// be checked directly against the phone's clock later.
enum Weekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const Weekday(this.isoValue);

  final int isoValue;
}

/// The interpreted rules for a parking spot -- what the AI reads off a
/// sign, structured so the app's clock can check it automatically, plus
/// the plain-language summary shown to users. Also what the confirm/edit
/// screen edits before a report is submitted.
@immutable
class ParkingRule {
  const ParkingRule({
    required this.summary,
    required this.freeDays,
    this.freeFromTime,
    this.freeToTime,
    this.maxDurationMinutes,
    this.exceptions,
  });

  /// Plain-language description in the viewer's app language, e.g.
  /// "Free parking, max 2 hours, Mon-Fri 8-18, residents exempt".
  final String summary;

  /// Which days of the week this rule applies to.
  final Set<Weekday> freeDays;

  /// Start of the free window on [freeDays]. Null (together with
  /// [freeToTime]) means free all day on those days.
  final TimeOfDay? freeFromTime;

  /// End of the free window on [freeDays].
  final TimeOfDay? freeToTime;

  /// Maximum stay, in minutes, if the sign specifies one. Null means no
  /// limit.
  final int? maxDurationMinutes;

  /// Free-text notes that don't fit the structured fields, e.g.
  /// "residents exempt" or "loading zone excluded".
  final String? exceptions;

  bool get isFreeAllDay => freeFromTime == null && freeToTime == null;

  /// Whether two rules describe the same underlying schedule -- used to
  /// tally matching correction reports. Ignores [summary]/[exceptions]
  /// free text, since two people describing the same rule may phrase it
  /// differently even when the structured schedule matches.
  bool isEquivalentTo(ParkingRule other) {
    return freeDays.length == other.freeDays.length &&
        freeDays.containsAll(other.freeDays) &&
        freeFromTime == other.freeFromTime &&
        freeToTime == other.freeToTime &&
        maxDurationMinutes == other.maxDurationMinutes;
  }

  ParkingRule copyWith({
    String? summary,
    Set<Weekday>? freeDays,
    TimeOfDay? freeFromTime,
    TimeOfDay? freeToTime,
    bool clearFreeTimes = false,
    int? maxDurationMinutes,
    String? exceptions,
  }) {
    return ParkingRule(
      summary: summary ?? this.summary,
      freeDays: freeDays ?? this.freeDays,
      freeFromTime: clearFreeTimes ? null : (freeFromTime ?? this.freeFromTime),
      freeToTime: clearFreeTimes ? null : (freeToTime ?? this.freeToTime),
      maxDurationMinutes: maxDurationMinutes ?? this.maxDurationMinutes,
      exceptions: exceptions ?? this.exceptions,
    );
  }
}
