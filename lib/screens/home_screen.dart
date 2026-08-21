import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/location_permission_service.dart';
import '../services/spots_repository.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/spots_list_view.dart';
import '../widgets/spots_map_view.dart';
import 'account_screen.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationPermissionService();
  final _spotsRepository = SpotsRepository();

  LocationAccessStatus _status = LocationAccessStatus.unknown;
  bool _checkingInitialStatus = true;

  bool _showListView = false;
  bool _loadingSpots = false;
  Position? _currentPosition;
  List<NearbySpot> _nearbySpots = const [];

  // Cached rather than read from widget.authService.isGuest directly in
  // build(): that getter touches FirebaseAuth, and build() must never
  // depend on a backend being reachable (or initialized at all, as in
  // widget tests). Defaults to true (guest) if it can't be determined --
  // showing an extra ad is a far safer failure mode than showing none.
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    try {
      _isGuest = widget.authService.isGuest;
    } catch (_) {
      // Keep the default.
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitialStatus());
  }

  Future<void> _checkInitialStatus() async {
    final status = await _locationService.checkStatus();
    if (!mounted) return;

    setState(() {
      _status = status;
      _checkingInitialStatus = false;
    });

    // First launch (or permission was reset): explain why we need location
    // before the OS prompt appears, rather than surprising the user with it.
    if (status == LocationAccessStatus.unknown ||
        status == LocationAccessStatus.denied) {
      _showLocationExplanationDialog();
    } else if (status == LocationAccessStatus.granted) {
      _loadNearbySpots();
    }
  }

  Future<void> _showLocationExplanationDialog() async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.locationPermissionDialogTitle),
        content: Text(l10n.locationPermissionDialogBody),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _requestPermission();
            },
            child: Text(l10n.locationPermissionContinue),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission() async {
    final status = await _locationService.requestPermission();
    if (!mounted) return;
    setState(() => _status = status);
    if (status == LocationAccessStatus.granted) {
      _loadNearbySpots();
    }
  }

  Future<void> _loadNearbySpots() async {
    setState(() => _loadingSpots = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final nearby = await _spotsRepository.fetchNearby(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _nearbySpots = nearby;
        _loadingSpots = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingSpots = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (_status == LocationAccessStatus.granted) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadingSpots ? null : _loadNearbySpots,
            ),
            IconButton(
              icon: Icon(_showListView ? Icons.map_outlined : Icons.list),
              tooltip: _showListView ? l10n.toggleToMapView : l10n.toggleToListView,
              onPressed: () => setState(() => _showListView = !_showListView),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: l10n.accountTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AccountScreen(authService: widget.authService),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _checkingInitialStatus
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(l10n),
      ),
      floatingActionButton: _status == LocationAccessStatus.granted
          ? FloatingActionButton(
              tooltip: l10n.addSpotTooltip,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaptureScreen()),
                );
                _loadNearbySpots();
              },
              child: const Icon(Icons.add_a_photo_outlined),
            )
          : null,
      // Guests get frequent full-screen ads instead (see main.dart); this
      // persistent strip is only for registered users, per the plan.
      bottomNavigationBar: _isGuest ? null : const BannerAdWidget(),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    switch (_status) {
      case LocationAccessStatus.granted:
        if (_loadingSpots || _currentPosition == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _showListView
            ? SpotsListView(spots: _nearbySpots)
            : SpotsMapView(
                currentLatitude: _currentPosition!.latitude,
                currentLongitude: _currentPosition!.longitude,
                spots: _nearbySpots,
              );

      case LocationAccessStatus.serviceDisabled:
        return _PermissionBlockedMessage(
          message: l10n.locationServicesDisabled,
          actionLabel: l10n.locationPermissionOpenSettings,
          onAction: _locationService.openLocationSettings,
        );

      case LocationAccessStatus.deniedForever:
        return _PermissionBlockedMessage(
          message: l10n.locationPermissionPermanentlyDenied,
          actionLabel: l10n.locationPermissionOpenSettings,
          onAction: _locationService.openAppSettings,
        );

      case LocationAccessStatus.denied:
      case LocationAccessStatus.unknown:
        return _PermissionBlockedMessage(
          message: l10n.locationPermissionDenied,
          actionLabel: l10n.locationPermissionRetry,
          onAction: _requestPermission,
        );
    }
  }
}

/// Full-screen message shown whenever the app can't proceed without
/// location access — the plan calls for GPS to be required, not optional.
class _PermissionBlockedMessage extends StatelessWidget {
  const _PermissionBlockedMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
