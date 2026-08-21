import 'package:geolocator/geolocator.dart';

/// The state of location access that the app cares about, collapsed down
/// from geolocator's service-enabled check and permission check into one
/// status the UI can switch on.
enum LocationAccessStatus {
  /// Permission has not been requested yet (or hasn't been checked yet).
  unknown,

  /// Permission is granted and location services are on — the app can use GPS.
  granted,

  /// The user denied the permission but can be asked again.
  denied,

  /// The user denied the permission permanently ("don't ask again"); only
  /// the phone's app settings screen can change this now.
  deniedForever,

  /// Permission may be granted, but the phone's location services (GPS) are
  /// switched off entirely.
  serviceDisabled,
}

/// Thin wrapper around the `geolocator` plugin so the rest of the app deals
/// with one small enum instead of geolocator's own permission/service types.
class LocationPermissionService {
  Future<LocationAccessStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _statusForPermission(permission);
  }

  /// Triggers the OS permission prompt. Call this only after the user has
  /// seen the in-app explanation of why location is needed.
  Future<LocationAccessStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    final permission = await Geolocator.requestPermission();
    return _statusForPermission(permission);
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  LocationAccessStatus _statusForPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationAccessStatus.granted;
      case LocationPermission.denied:
        return LocationAccessStatus.denied;
      case LocationPermission.deniedForever:
        return LocationAccessStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationAccessStatus.denied;
    }
  }
}
