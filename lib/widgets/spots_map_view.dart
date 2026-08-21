import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../models/spot.dart';
import '../screens/spot_detail_screen.dart';
import '../services/spots_repository.dart';

/// The real map view (OpenStreetMap via flutter_map), replacing the
/// placeholder from the skeleton. Shows nearby spots as pins colored by
/// [SpotStatusCalculator] -- green/red/grey per the plan's "Two kinds of
/// free" rules.
class SpotsMapView extends StatelessWidget {
  const SpotsMapView({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.spots,
  });

  final double currentLatitude;
  final double currentLongitude;
  final List<NearbySpot> spots;

  @override
  Widget build(BuildContext context) {
    final center = ll.LatLng(currentLatitude, currentLongitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.freeparkingfinland.free_parking_finland',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 22,
              height: 22,
              child: const _CurrentLocationDot(),
            ),
            for (final nearby in spots)
              Marker(
                point: ll.LatLng(nearby.spot.latitude, nearby.spot.longitude),
                width: 40,
                height: 40,
                child: _SpotPin(
                  spot: nearby.spot,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SpotDetailScreen(spot: nearby.spot)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }
}

class _SpotPin extends StatelessWidget {
  const _SpotPin({required this.spot, required this.onTap});

  final Spot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = SpotStatusCalculator.statusOf(spot);
    final color = switch (status) {
      SpotStatus.green => Colors.green,
      SpotStatus.red => Colors.red,
      SpotStatus.grey => Colors.grey,
    };

    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.location_pin, color: color, size: 40),
    );
  }
}
