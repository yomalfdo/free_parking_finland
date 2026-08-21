import 'package:geolocator/geolocator.dart';

import '../models/spot.dart';
import 'firestore_service.dart';

/// A spot alongside its distance from wherever the user is looking (their
/// current location, or a pin they've dropped elsewhere).
class NearbySpot {
  const NearbySpot({required this.spot, required this.distanceMeters});

  final Spot spot;
  final double distanceMeters;
}

/// Loads spots and narrows them down to what the "Finding a spot" flow
/// needs: sorted nearest-first, within a 1km radius of a reference point.
class SpotsRepository {
  SpotsRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  static const radiusMeters = 1000.0;

  Future<List<NearbySpot>> fetchNearby({
    required double latitude,
    required double longitude,
  }) async {
    final spots = await _firestoreService.fetchAllSpots();

    final nearby = spots
        .map((spot) => NearbySpot(
              spot: spot,
              distanceMeters: Geolocator.distanceBetween(
                latitude,
                longitude,
                spot.latitude,
                spot.longitude,
              ),
            ))
        .where((nearbySpot) => nearbySpot.distanceMeters <= radiusMeters)
        .toList();

    nearby.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return nearby;
  }
}
