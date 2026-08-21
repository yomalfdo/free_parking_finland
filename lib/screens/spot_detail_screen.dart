import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/spot.dart';
import 'capture_screen.dart';

/// Shows a spot's rules and how old the report is, with a button to hand
/// off to Google Maps for turn-by-turn directions. Apple Maps joins this
/// choice once the iOS build exists (plan step 5 note) -- Android-only
/// for now, so there's nothing to choose between yet.
class SpotDetailScreen extends StatelessWidget {
  const SpotDetailScreen({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = SpotStatusCalculator.statusOf(spot);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.spotDetailTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(status: status, l10n: l10n),
              const SizedBox(height: 16),
              Text(spot.rule.summary, style: Theme.of(context).textTheme.titleMedium),
              if (spot.rule.exceptions != null) ...[
                const SizedBox(height: 8),
                Text(spot.rule.exceptions!),
              ],
              const SizedBox(height: 12),
              Text(
                _reportedAgoText(l10n, spot.reportedAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(l10n.reportButton),
                  onPressed: () => _report(context),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.navigation_outlined),
                  label: Text(l10n.navigateButton),
                  onPressed: () => _navigate(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _reportedAgoText(AppLocalizations l10n, DateTime reportedAt) {
    final diff = DateTime.now().difference(reportedAt);
    if (diff.inMinutes < 1) return l10n.justNowLabel;
    if (diff.inHours < 1) return l10n.reportedMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.reportedHoursAgo(diff.inHours);
    return l10n.reportedDaysAgo(diff.inDays);
  }

  Future<void> _navigate(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${spot.latitude},${spot.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _report(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaptureScreen(correctionForSpotId: spot.id),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.l10n});

  final SpotStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SpotStatus.green => (Colors.green, l10n.statusFreeNowLabel),
      SpotStatus.red => (Colors.red, l10n.statusReportedFullLabel),
      SpotStatus.grey => (Colors.grey, l10n.statusNotFreeNowLabel),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
