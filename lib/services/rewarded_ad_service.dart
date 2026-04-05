import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

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
          debugPrint('Rewarded ad loaded ✅');
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
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
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onRewarded(); // ← activate ad-free here
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
