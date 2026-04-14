import 'package:Spendara/core/analytics/analytics_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';
import '../core/crashlytics/crashlytics_keys.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // ── Preload ad (call on app start or before showing) ───────────────
  void loadAd() {
    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;
          FirebaseAnalytics.instance.logEvent(
            name: AnalyticsKeys.rewardedAdLoaded,
          );
          debugPrint('Rewarded ad loaded ✅');
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          FirebaseCrashlytics.instance.log(
            '${CrashlyticsKeys.rewardedAdLoad}_$error',
          );
          debugPrint('Rewarded ad failed: $error');
        },
      ),
    );
  }

  // ── Show ad → onRewarded called if user watches fully ──────────────
  void showAd({
    required VoidCallback onRewarded,
    required VoidCallback onNotLoaded,
  }) {
    if (!_isLoaded || _rewardedAd == null) {
      onNotLoaded();
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.adNotLoaded);
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isLoaded = false;
        loadAd(); // preload next ad immediately
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isLoaded = false;
        debugPrint(
          '❌ Rewarded failed → Code: ${error.code} | Message:${error.message}',
        );
        loadAd();
        FirebaseCrashlytics.instance.log(
          '${CrashlyticsKeys.rewardedAdFull}_$error',
        );
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onRewarded(); // ← activate ad-free here
        FirebaseAnalytics.instance.logEvent(name: AnalyticsKeys.rewarded);
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
