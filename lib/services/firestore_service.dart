import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/parking_rule.dart';
import '../models/spot.dart';

/// Thin wrapper around Firestore.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;
  FirebaseFirestore get _db => _injectedFirestore ?? FirebaseFirestore.instance;

  /// Writes and reads back a small document to confirm the app can
  /// actually reach Firestore with the current security rules -- used
  /// during setup, not part of any real feature.
  Future<bool> checkConnection() async {
    final doc = _db.collection('_healthcheck').doc('ping');
    await doc.set({'checkedAt': FieldValue.serverTimestamp()});
    final snapshot = await doc.get();
    return snapshot.exists;
  }

  /// Saves a confirmed spot report. The photo itself is never uploaded or
  /// stored anywhere -- only the interpreted rule, location, and who/when
  /// reported it. Reporting a spot is itself a live confirmation that it's
  /// free right now, so this also sets the initial crowd-confirmed status
  /// (see [Spot] / [SpotStatusCalculator] for how that combines with the
  /// rule-based schedule to decide the map pin color).
  Future<void> submitSpotReport({
    required double latitude,
    required double longitude,
    required ParkingRule rule,
    required String? reportedByUid,
  }) async {
    await _db.collection('spots').add({
      'location': GeoPoint(latitude, longitude),
      'summary': rule.summary,
      'freeDays': (rule.freeDays.map((d) => d.isoValue).toList()..sort()),
      'freeFromMinutes': _minutesSinceMidnight(rule.freeFromTime),
      'freeToMinutes': _minutesSinceMidnight(rule.freeToTime),
      'maxDurationMinutes': rule.maxDurationMinutes,
      'exceptions': (rule.exceptions?.trim().isEmpty ?? true) ? null : rule.exceptions!.trim(),
      'reportedBy': reportedByUid,
      'reportedAt': FieldValue.serverTimestamp(),
      'liveStatus': 'free',
      'liveStatusAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches every spot currently in Firestore. Filtering to a radius and
  /// sorting by distance happens client-side in [SpotsRepository] -- fine
  /// at this scale, and avoids needing geohash-based queries for a v1.
  Future<List<Spot>> fetchAllSpots() async {
    final snapshot = await _db.collection('spots').get();
    return snapshot.docs.map((doc) => Spot.fromFirestore(doc.id, doc.data())).toList();
  }

  /// Reporters needed before a correction is actually applied --
  /// self-moderation instead of a review queue: nobody's word is trusted
  /// alone, but three independent people photographing the same sign and
  /// landing on the same reading is treated as ground truth.
  static const correctionsRequiredToApply = 3;

  /// Submits a correction proposal for [spotId]: "the rule here is
  /// actually X." One proposal per reporter -- reporting again just
  /// replaces that reporter's previous proposal rather than counting
  /// twice. Once [correctionsRequiredToApply] reporters land on the same
  /// structured schedule (see [ParkingRule.isEquivalentTo]), it's applied
  /// to the spot and every proposal is cleared. No photo is ever stored --
  /// only the agreed-on rule data, same as the original report flow.
  Future<void> submitCorrection({
    required String spotId,
    required ParkingRule rule,
    required String? reportedByUid,
  }) async {
    final corrections = _db.collection('spots').doc(spotId).collection('corrections');
    final proposalId = reportedByUid ?? corrections.doc().id;

    await corrections.doc(proposalId).set({
      'freeDays': (rule.freeDays.map((d) => d.isoValue).toList()..sort()),
      'freeFromMinutes': _minutesSinceMidnight(rule.freeFromTime),
      'freeToMinutes': _minutesSinceMidnight(rule.freeToTime),
      'maxDurationMinutes': rule.maxDurationMinutes,
      'summary': rule.summary,
      'exceptions': (rule.exceptions?.trim().isEmpty ?? true) ? null : rule.exceptions!.trim(),
      'reportedBy': reportedByUid,
      'reportedAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await corrections.get();
    final proposals = snapshot.docs.map((doc) => _ruleFromCorrectionData(doc.data())).toList();

    for (final candidate in proposals) {
      final matchCount = proposals.where(candidate.isEquivalentTo).length;
      if (matchCount < correctionsRequiredToApply) continue;

      final batch = _db.batch();
      batch.update(_db.collection('spots').doc(spotId), {
        'summary': candidate.summary,
        'freeDays': (candidate.freeDays.map((d) => d.isoValue).toList()..sort()),
        'freeFromMinutes': _minutesSinceMidnight(candidate.freeFromTime),
        'freeToMinutes': _minutesSinceMidnight(candidate.freeToTime),
        'maxDurationMinutes': candidate.maxDurationMinutes,
        'exceptions':
            (candidate.exceptions?.trim().isEmpty ?? true) ? null : candidate.exceptions!.trim(),
      });
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return;
    }
  }

  ParkingRule _ruleFromCorrectionData(Map<String, dynamic> data) {
    final freeDaysRaw = data['freeDays'] as List<dynamic>? ?? const [];
    final freeDays = freeDaysRaw
        .map((v) => v as int)
        .map((iso) => Weekday.values.firstWhere((d) => d.isoValue == iso))
        .toSet();
    return ParkingRule(
      summary: data['summary'] as String? ?? '',
      freeDays: freeDays,
      freeFromTime: _timeOfMinutes(data['freeFromMinutes'] as int?),
      freeToTime: _timeOfMinutes(data['freeToMinutes'] as int?),
      maxDurationMinutes: data['maxDurationMinutes'] as int?,
      exceptions: data['exceptions'] as String?,
    );
  }

  int? _minutesSinceMidnight(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  TimeOfDay? _timeOfMinutes(int? minutes) {
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
