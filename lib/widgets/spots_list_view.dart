import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/spot.dart';
import '../screens/spot_detail_screen.dart';
import '../services/spots_repository.dart';

/// The same nearby spots as the map, shown as a sorted list -- the plan's
/// "list view" toggle for finding a spot.
class SpotsListView extends StatelessWidget {
  const SpotsListView({super.key, required this.spots});

  final List<NearbySpot> spots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (spots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.noSpotsNearbyMessage, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: spots.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final nearby = spots[index];
        final status = SpotStatusCalculator.statusOf(nearby.spot);
        final color = switch (status) {
          SpotStatus.green => Colors.green,
          SpotStatus.red => Colors.red,
          SpotStatus.grey => Colors.grey,
        };

        return ListTile(
          leading: Icon(Icons.circle, color: color, size: 16),
          title: Text(nearby.spot.rule.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Text(_distanceText(l10n, nearby.distanceMeters)),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SpotDetailScreen(spot: nearby.spot)),
          ),
        );
      },
    );
  }

  String _distanceText(AppLocalizations l10n, double meters) {
    if (meters < 1000) {
      return l10n.distanceMetersValue(meters.round());
    }
    return l10n.distanceKilometersValue((meters / 1000).toStringAsFixed(1));
  }
}
