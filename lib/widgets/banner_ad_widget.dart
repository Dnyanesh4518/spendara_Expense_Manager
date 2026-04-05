import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';
import '../features/ads/cubit/ad_free_cubit.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd; // ← defined here
  bool _isLoaded = false; // ← defined here
  bool _loadAttempted = false; // ← prevents loading ad twice

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadAttempted) {
      _loadAttempted = true; // ← ensures _loadAd() only runs once
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );
    if (size == null) return;

    BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check ad-free state — hide banner if active
    return BlocBuilder<AdFreeCubit, AdFreeState>(
      builder: (context, adFreeState) {
        // Hide banner during ad-free period
        if (adFreeState.isAdFree) return const SizedBox.shrink();

        // Hide if ad not loaded yet
        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      },
    );
  }
}
