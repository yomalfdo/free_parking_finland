import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_localizations.dart';
import '../models/parking_rule.dart';
import '../services/ai_interpretation_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Shows the AI's interpretation of the photographed sign and lets the
/// user edit it before submitting. The photo itself is never uploaded to
/// Firebase -- Gemini reads it directly from the app via Firebase AI
/// Logic, and the local file is deleted once this screen is done with it,
/// win or lose.
class ConfirmSpotScreen extends StatefulWidget {
  const ConfirmSpotScreen({
    super.key,
    required this.photoPath,
    required this.position,
    this.correctionForSpotId,
  });

  final String photoPath;
  final Position position;

  /// When set, submitting here corrects the rules on an existing spot
  /// instead of creating a new one.
  final String? correctionForSpotId;

  @override
  State<ConfirmSpotScreen> createState() => _ConfirmSpotScreenState();
}

class _ConfirmSpotScreenState extends State<ConfirmSpotScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _aiService = AiInterpretationService();

  bool _interpreting = true;
  bool _submitting = false;
  String? _interpretError;

  ParkingRule? _rule;
  final _summaryController = TextEditingController();
  final _exceptionsController = TextEditingController();

  static const _durationOptions = <int?>[null, 30, 60, 120, 180, 240];

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame so AppLocalizations (needed to
    // pick which language Gemini writes the summary in) is guaranteed
    // available via context.
    WidgetsBinding.instance.addPostFrameCallback((_) => _interpretPhoto());
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _exceptionsController.dispose();
    // Best-effort cleanup -- the photo is never meant to outlive this
    // screen, whether the report gets submitted or abandoned.
    File(widget.photoPath).delete().catchError((_) => File(widget.photoPath));
    super.dispose();
  }

  Future<void> _interpretPhoto() async {
    setState(() {
      _interpreting = true;
      _interpretError = null;
    });

    try {
      final photoBytes = await File(widget.photoPath).readAsBytes();
      if (!mounted) return;

      final languageName = _languageNameFor(Localizations.localeOf(context).languageCode);
      final rule = await _aiService.interpretSign(photoBytes, languageName: languageName);

      if (!mounted) return;
      setState(() {
        _rule = rule;
        _summaryController.text = rule.summary;
        _exceptionsController.text = rule.exceptions ?? '';
        _interpreting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _interpreting = false;
        _interpretError = AppLocalizations.of(context)!.authGenericError;
      });
    }
  }

  String _languageNameFor(String languageCode) {
    switch (languageCode) {
      case 'fi':
        return 'Finnish';
      case 'sv':
        return 'Swedish';
      default:
        return 'English';
    }
  }

  void _toggleDay(Weekday day, bool selected) {
    setState(() {
      final days = Set<Weekday>.from(_rule!.freeDays);
      selected ? days.add(day) : days.remove(day);
      _rule = _rule!.copyWith(freeDays: days);
    });
  }

  void _setAllDay(bool allDay) {
    setState(() {
      _rule = allDay
          ? _rule!.copyWith(clearFreeTimes: true)
          : _rule!.copyWith(
              freeFromTime: const TimeOfDay(hour: 8, minute: 0),
              freeToTime: const TimeOfDay(hour: 18, minute: 0),
            );
    });
  }

  Future<void> _pickTime({required bool isFrom}) async {
    final initial = (isFrom ? _rule!.freeFromTime : _rule!.freeToTime) ??
        const TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      _rule = isFrom ? _rule!.copyWith(freeFromTime: picked) : _rule!.copyWith(freeToTime: picked);
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final rule = _rule!.copyWith(
        summary: _summaryController.text.trim(),
        exceptions: _exceptionsController.text,
      );
      final correctionForSpotId = widget.correctionForSpotId;
      if (correctionForSpotId != null) {
        await _firestoreService.submitCorrection(
          spotId: correctionForSpotId,
          rule: rule,
          reportedByUid: _authService.currentUser?.uid,
        );
      } else {
        await _firestoreService.submitSpotReport(
          latitude: widget.position.latitude,
          longitude: widget.position.longitude,
          rule: rule,
          reportedByUid: _authService.currentUser?.uid,
        );
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            correctionForSpotId != null ? l10n.correctionSubmittedMessage : l10n.spotSubmittedMessage,
          ),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.authGenericError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.confirmScreenTitle)),
      body: SafeArea(
        child: _interpreting
            ? const Center(child: CircularProgressIndicator())
            : _interpretError != null
                ? _buildInterpretError(l10n)
                : _buildForm(l10n),
      ),
    );
  }

  Widget _buildInterpretError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_interpretError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelButton),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _interpretPhoto,
                  child: Text(l10n.locationPermissionRetry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(widget.correctionForSpotId != null ? l10n.reportConfirmInstructions : l10n.confirmInstructions),
        const SizedBox(height: 20),
        Text(l10n.summaryLabel, style: Theme.of(context).textTheme.labelLarge),
        TextField(
          controller: _summaryController,
          maxLines: 2,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        Text(l10n.freeDaysLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Weekday.values.map((day) {
            return FilterChip(
              label: Text(_dayLabel(l10n, day)),
              selected: _rule!.freeDays.contains(day),
              onSelected: (selected) => _toggleDay(day, selected),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(l10n.freeHoursLabel, style: Theme.of(context).textTheme.labelLarge),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.allDayToggleLabel),
          value: _rule!.isFreeAllDay,
          onChanged: _setAllDay,
        ),
        if (!_rule!.isFreeAllDay)
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: l10n.fromTimeLabel,
                  time: _rule!.freeFromTime!,
                  onTap: () => _pickTime(isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: l10n.toTimeLabel,
                  time: _rule!.freeToTime!,
                  onTap: () => _pickTime(isFrom: false),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Text(l10n.maxDurationLabel, style: Theme.of(context).textTheme.labelLarge),
        DropdownButtonFormField<int?>(
          initialValue: _rule!.maxDurationMinutes,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: _durationOptions
              .map((minutes) => DropdownMenuItem(
                    value: minutes,
                    child: Text(minutes == null ? l10n.noLimitLabel : l10n.minutesValue(minutes)),
                  ))
              .toList(),
          onChanged: (minutes) => setState(() => _rule = _rule!.copyWith(maxDurationMinutes: minutes)),
        ),
        const SizedBox(height: 20),
        Text(l10n.exceptionsLabel, style: Theme.of(context).textTheme.labelLarge),
        TextField(
          controller: _exceptionsController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: l10n.exceptionsHint,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancelButton),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.correctionForSpotId != null
                            ? l10n.submitCorrectionButton
                            : l10n.confirmAndSubmitButton,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _dayLabel(AppLocalizations l10n, Weekday day) {
    switch (day) {
      case Weekday.monday:
        return l10n.dayMonday;
      case Weekday.tuesday:
        return l10n.dayTuesday;
      case Weekday.wednesday:
        return l10n.dayWednesday;
      case Weekday.thursday:
        return l10n.dayThursday;
      case Weekday.friday:
        return l10n.dayFriday;
      case Weekday.saturday:
        return l10n.daySaturday;
      case Weekday.sunday:
        return l10n.daySunday;
    }
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.time, required this.onTap});

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(time.format(context)),
      ),
    );
  }
}
