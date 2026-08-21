import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On Android, the google-services Gradle plugin injects the project
  // config from google-services.json, so no explicit FirebaseOptions are
  // needed here. Revisit this once iOS/web are added.
  await Firebase.initializeApp();

  // App Check protects the Gemini API key from abuse without embedding a
  // static secret in the app. AndroidProvider.debug is for development
  // only -- it prints a debug token to logcat on first run that has to be
  // registered in the Firebase console. Switch to playIntegrity before
  // release.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
  );

  final authService = AuthService();
  // Guests get a usable app with no signup step -- an anonymous session
  // starts automatically and can be upgraded to a real account later.
  // This must never block app launch: a config issue (e.g. anonymous
  // sign-in not yet enabled in the Firebase console) or a network hiccup
  // shouldn't leave the user stuck on the splash screen forever. The
  // account screen offers a retry if this fails.
  try {
    await authService.ensureSignedIn();
  } catch (e) {
    debugPrint('Guest sign-in failed, continuing without a session: $e');
  }

  final adsService = AdsService();
  await adsService.initialize();

  runApp(FreeParkingApp(authService: authService, adsService: adsService));
}

class FreeParkingApp extends StatefulWidget {
  const FreeParkingApp({super.key, required this.authService, required this.adsService});

  final AuthService authService;
  final AdsService adsService;

  @override
  State<FreeParkingApp> createState() => _FreeParkingAppState();
}

class _FreeParkingAppState extends State<FreeParkingApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  int _tapCount = 0;

  static const _tapsBetweenGuestAds = 5;

  @override
  void initState() {
    super.initState();
    // Ads are never allowed to crash the app -- a failed preload just
    // means the first interstitial doesn't show, which is a fine fallback.
    widget.adsService.preloadInterstitial().catchError((_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLaunch());
  }

  Future<void> _onLaunch() async {
    try {
      if (widget.authService.isGuest) {
        // A brief pause so the first ad doesn't appear before anything
        // else has had a chance to render.
        await Future.delayed(const Duration(milliseconds: 500));
        await widget.adsService.showInterstitialIfReady();
      } else {
        final due = await widget.adsService.shouldShowRegisteredUserInterstitial();
        if (due) {
          await Future.delayed(const Duration(milliseconds: 500));
          await widget.adsService.showInterstitialIfReady();
          await widget.adsService.recordRegisteredUserInterstitialShown();
        }
      }
    } catch (e) {
      debugPrint('Launch ad check failed, continuing without it: $e');
    }
  }

  void _onTap() {
    try {
      // Registered users don't get the frequent tap-triggered ads -- just
      // guests, per the plan's "Accounts & ads" section.
      if (!widget.authService.isGuest) return;

      _tapCount++;
      if (_tapCount >= _tapsBetweenGuestAds) {
        _tapCount = 0;
        widget.adsService.showInterstitialIfReady(onDismissed: _showRegisterNudge);
      }
    } catch (e) {
      debugPrint('Tap ad check failed, continuing without it: $e');
    }
  }

  void _showRegisterNudge() {
    // Uses the ScaffoldMessenger's own context rather than this State's --
    // this State's context sits above MaterialApp (which is what it
    // builds), so it's outside the Localizations scope MaterialApp
    // provides and AppLocalizations.of would always return null there.
    final messengerContext = _scaffoldMessengerKey.currentContext;
    if (messengerContext == null) return;
    final l10n = AppLocalizations.of(messengerContext);
    if (l10n == null) return;

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(l10n.registerToRemoveAdsMessage),
        action: SnackBarAction(
          label: l10n.createAccountAction,
          onPressed: () {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => AccountScreen(authService: widget.authService),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      builder: (context, child) => Listener(
        onPointerDown: (_) => _onTap(),
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
      home: HomeScreen(authService: widget.authService),
    );
  }
}
