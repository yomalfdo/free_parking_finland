import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay, immutable;

import 'parking_rule.dart';

/// What the last person nearby actually reported, separate from what the
/// sign's rule says. Expires after 30 minutes (see [SpotStatus]).
enum LiveStatus { free, full }

/// A saved parking spot: the interpreted rule from the sign, where it is,
/// and the freshest crowd report. This is the "spots" Firestore document
/// shape written by [FirestoreService.submitSpotReport] in the reporting
/// flow (plan step 4), read back here for the map/list (plan step 5).
@immutable
class Spot {
  const Spot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.rule,
    required this.reportedAt,
    this.reportedBy,
    this.liveStatus,
    this.liveStatusAt,
  });

  final String id;
  final double latitude;
  final double longitude;
  final ParkingRule rule;
  final DateTime reportedAt;
  final String? reportedBy;
  final LiveStatus? liveStatus;
  final DateTime? liveStatusAt;

  factory Spot.fromFirestore(String id, Map<String, dynamic> data) {
    final freeDaysRaw = data['freeDays'] as List<dynamic>? ?? const [];
    final freeDays = freeDaysRaw
        .map((v) => v as int)
        .map((iso) => Weekday.values.firstWhere((d) => d.isoValue == iso))
        .toSet();

    final freeFromMinutes = data['freeFromMinutes'] as int?;
    final freeToMinutes = data['freeToMinutes'] as int?;

    final liveStatusRaw = data['liveStatus'] as String?;
    final liveStatusAtRaw = data['liveStatusAt'] as Timestamp?;

    return Spot(
      id: id,
      latitude: (data['location'] as GeoPoint).latitude,
      longitude: (data['location'] as GeoPoint).longitude,
      rule: ParkingRule(
        summary: data['summary'] as String? ?? '',
        freeDays: freeDays,
        freeFromTime: _timeOfMinutes(freeFromMinutes),
        freeToTime: _timeOfMinutes(freeToMinutes),
        maxDurationMinutes: data['maxDurationMinutes'] as int?,
        exceptions: data['exceptions'] as String?,
      ),
      reportedAt: (data['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reportedBy: data['reportedBy'] as String?,
      liveStatus: liveStatusRaw == null
          ? null
          : LiveStatus.values.firstWhere((s) => s.name == liveStatusRaw),
      liveStatusAt: liveStatusAtRaw?.toDate(),
    );
  }

  static TimeOfDay? _timeOfMinutes(int? minutes) {
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}

/// How a spot should be shown right now: green (free), red (reported
/// full), or grey (outside its free hours, or unconfirmed).
enum SpotStatus { green, red, grey }

/// Combines the sign's rule-based schedule with the freshest crowd report
/// to decide how a spot should be colored on the map, per the plan's
/// "Two kinds of free" section.
class SpotStatusCalculator {
  const SpotStatusCalculator._();

  static const liveStatusExpiry = Duration(minutes: 30);

  static SpotStatus statusOf(Spot spot, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final liveConfirmedRecently = spot.liveStatusAt != null &&
        currentTime.difference(spot.liveStatusAt!) < liveStatusExpiry;

    // A recent "full" report always wins, even over a rule that says free.
    if (liveConfirmedRecently && spot.liveStatus == LiveStatus.full) {
      return SpotStatus.red;
    }

    if (liveConfirmedRecently && spot.liveStatus == LiveStatus.free) {
      return SpotStatus.green;
    }

    if (isRuleFreeAt(spot.rule, currentTime)) {
      return SpotStatus.green;
    }

    return SpotStatus.grey;
  }

  /// Whether the sign's rule alone says this spot is free at [time], with
  /// no crowd report involved.
  static bool isRuleFreeAt(ParkingRule rule, DateTime time) {
    final today = Weekday.values.firstWhere((d) => d.isoValue == time.weekday);
    if (!rule.freeDays.contains(today)) return false;
    if (rule.isFreeAllDay) return true;

    final minutesNow = time.hour * 60 + time.minute;
    final fromMinutes = rule.freeFromTime!.hour * 60 + rule.freeFromTime!.minute;
    final toMinutes = rule.freeToTime!.hour * 60 + rule.freeToTime!.minute;
    return minutesNow >= fromMinutes && minutesNow <= toMinutes;
  }
}
