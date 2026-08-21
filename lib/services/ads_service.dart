import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps AdMob for the two ad behaviors the plan specifies: frequent
/// full-screen ads for guests, and occasional ones (plus a persistent
/// banner) for registered users. Uses Google's public TEST ad unit IDs --
/// swap these for real ones from your own AdMob account before release.
class AdsService {
  // TEST ad units (safe to ship in debug builds, always serve test ads).
  static const bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static const _lastFullScreenAdKey = 'last_full_screen_ad_at';
  // Plan says "roughly weekly to monthly, tuned to ad revenue" -- starting
  // at two weeks as a reasonable middle ground, easy to retune later.
  static const registeredUserAdInterval = Duration(days: 14);

  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  Future<void> initialize() => MobileAds.instance.initialize();

  Future<void> preloadInterstitial() => _loadInterstitial();

  Future<void> _loadInterstitial() async {
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (_) {
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if one's ready, and starts loading
  /// the next one either way. Silently does nothing if none is ready --
  /// ads are never worth blocking the app over.
  ///
  /// [onDismissed], if given, fires once the user is actually back in the
  /// app -- i.e. after the ad closes, not after `ad.show()` returns (that
  /// Future completes as soon as the native ad activity is launched, well
  /// before the user has seen or dismissed it).
  Future<void> showInterstitialIfReady({VoidCallback? onDismissed}) async {
    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(_loadInterstitial());
      onDismissed?.call();
      return;
    }
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitial());
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(_loadInterstitial());
        onDismissed?.call();
      },
    );
    await ad.show();
  }

  /// Whether it's been long enough since a registered user last saw a
  /// full-screen ad to show them another one.
  Future<bool> shouldShowRegisteredUserInterstitial() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastFullScreenAdKey);
    if (lastMs == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    return DateTime.now().difference(last) >= registeredUserAdInterval;
  }

  Future<void> recordRegisteredUserInterstitialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastFullScreenAdKey, DateTime.now().millisecondsSinceEpoch);
  }
}
