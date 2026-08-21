import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_localizations.dart';
import 'confirm_spot_screen.dart';

/// Opens the device camera in-app so the user can photograph a parking
/// sign, capturing the current GPS location at the same moment. GPS
/// permission is already guaranteed by the time this screen is reachable
/// (the whole app requires it), so only camera access is checked here.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.correctionForSpotId});

  /// When set, this capture is a correction report for an existing spot
  /// rather than a brand new one -- forwarded to [ConfirmSpotScreen] to
  /// pick which Firestore write it submits.
  final String? correctionForSpotId;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  bool _initializing = true;
  bool _capturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('noCamera', 'No camera available on this device');
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = AppLocalizations.of(context)!.cameraPermissionDenied;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndContinue() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _capturing = true);

    try {
      final photo = await controller.takePicture();
      // A GPS fix can be slow or never arrive (weak signal, indoors, or a
      // quirky emulator) -- without a limit this would hang forever with
      // no way for the user to back out.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmSpotScreen(
            photoPath: photo.path,
            position: position,
            correctionForSpotId: widget.correctionForSpotId,
          ),
        ),
      );
      if (mounted) setState(() => _capturing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.captureFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isCorrection = widget.correctionForSpotId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isCorrection ? l10n.reportScreenTitle : l10n.captureScreenTitle),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_photography_outlined, size: 48, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: Geolocator.openAppSettings,
                child: Text(l10n.cameraPermissionOpenSettings),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Positioned(
          top: 16,
          left: 24,
          right: 24,
          child: Text(
            widget.correctionForSpotId != null ? l10n.reportInstructions : l10n.captureInstructions,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              shadows: [Shadow(blurRadius: 8, color: Colors.black)],
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: _capturing
                ? const CircularProgressIndicator(color: Colors.white)
                : GestureDetector(
                    onTap: _captureAndContinue,
                    child: Semantics(
                      label: l10n.captureButtonLabel,
                      button: true,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black26, width: 3),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
