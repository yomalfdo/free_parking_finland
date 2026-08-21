import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../models/parking_rule.dart';

/// Sends a photographed parking sign to Gemini (via Firebase AI Logic) and
/// parses the response into a [ParkingRule]. Called directly from the app
/// -- Firebase App Check protects the API key, so no backend proxy is
/// needed (see the plan's "Reporting a spot" flow for why this replaced
/// the original Cloud Function design).
class AiInterpretationService {
  AiInterpretationService({GenerativeModel? model}) : _model = model ?? _buildModel();

  final GenerativeModel _model;

  static GenerativeModel _buildModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.7-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'summary': Schema.string(
              description:
                  'Short plain-language summary of the parking rule, in the requested language, '
                  'e.g. "Free parking, max 2 hours, Mon-Fri 8-18, residents exempt".',
            ),
            'freeDays': Schema.array(
              description: 'ISO weekday numbers (1=Monday .. 7=Sunday) this rule applies to.',
              items: Schema.integer(),
            ),
            'isFreeAllDay': Schema.boolean(
              description: 'True if free all day on the listed days, false if limited to a time window.',
            ),
            'freeFromHour': Schema.integer(
              description: 'Start hour (0-23) of the free window. Use 0 if isFreeAllDay is true.',
            ),
            'freeFromMinute': Schema.integer(
              description: 'Start minute (0-59) of the free window. Use 0 if isFreeAllDay is true.',
            ),
            'freeToHour': Schema.integer(
              description: 'End hour (0-23) of the free window. Use 23 if isFreeAllDay is true.',
            ),
            'freeToMinute': Schema.integer(
              description: 'End minute (0-59) of the free window. Use 59 if isFreeAllDay is true.',
            ),
            'hasMaxDuration': Schema.boolean(
              description: 'True if the sign specifies a maximum stay duration.',
            ),
            'maxDurationMinutes': Schema.integer(
              description: 'Maximum stay in minutes if hasMaxDuration is true, otherwise 0.',
            ),
            'hasExceptions': Schema.boolean(
              description: 'True if the sign lists exceptions (e.g. residents exempt).',
            ),
            'exceptions': Schema.string(
              description: 'Free-text exceptions if hasExceptions is true, otherwise an empty string.',
            ),
          },
        ),
      ),
    );
  }

  Future<ParkingRule> interpretSign(Uint8List photoBytes, {required String languageName}) async {
    final prompt =
        'You are reading a parking sign photographed in Finland. Signs may be in Finnish, '
        'Swedish, or English. Work out the parking rules from the sign and respond only with '
        'the JSON described by the schema. Write the "summary" field in $languageName, as a '
        'short plain-language sentence a driver would understand. If the sign indicates free '
        'parking every day, include all 7 days in freeDays. If a field cannot be determined '
        'from the sign, use your best reasonable judgement.';

    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        InlineDataPart('image/jpeg', photoBytes),
      ]),
    ]);

    final jsonText = response.text;
    if (jsonText == null || jsonText.isEmpty) {
      throw StateError('Gemini returned no content');
    }

    final data = jsonDecode(jsonText) as Map<String, dynamic>;
    return _parseRule(data);
  }

  ParkingRule _parseRule(Map<String, dynamic> data) {
    final freeDaysRaw = data['freeDays'] as List<dynamic>? ?? const [];
    final freeDays = freeDaysRaw
        .map((v) => v as int)
        .map((iso) => Weekday.values.firstWhere((d) => d.isoValue == iso))
        .toSet();

    final isAllDay = data['isFreeAllDay'] as bool? ?? true;
    final hasMaxDuration = data['hasMaxDuration'] as bool? ?? false;
    final hasExceptions = data['hasExceptions'] as bool? ?? false;

    return ParkingRule(
      summary: data['summary'] as String? ?? '',
      freeDays: freeDays,
      freeFromTime: isAllDay ? null : _timeOf(data['freeFromHour'], data['freeFromMinute']),
      freeToTime: isAllDay ? null : _timeOf(data['freeToHour'], data['freeToMinute']),
      maxDurationMinutes: hasMaxDuration ? data['maxDurationMinutes'] as int? : null,
      exceptions: hasExceptions ? data['exceptions'] as String? : null,
    );
  }

  TimeOfDay? _timeOf(dynamic hour, dynamic minute) {
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour as int, minute: minute as int);
  }
}
