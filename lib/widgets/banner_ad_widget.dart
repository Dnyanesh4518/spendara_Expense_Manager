import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _loadAttempted = false;

  // Tracks whether the last load attempt actually failed
  // so we know a retry is needed when connectivity returns
  bool _failedDueToNoInternet = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadAttempted) {
      _loadAttempted = true;
      _loadAd();
    }
  }

  // ── Watch connectivity changes ─────────────────────────────
  void _listenToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);

      if (hasConnection && _failedDueToNoInternet && !_isLoaded) {
        debugPrint('Internet restored — retrying banner ad load');
        _failedDueToNoInternet = false;
        _retryLoad();
      }
    });
  }

  // ── Initial load (called once via didChangeDependencies) ───
  Future<void> _loadAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );
    if (size == null) return;
    _buildAndLoadBanner(size);
  }

  // ── Retry load (called when connectivity is restored) ──────
  Future<void> _retryLoad() async {
    // Dispose stale ad object before creating a new one
    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) setState(() => _isLoaded = false);

    if (!mounted) return;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );
    if (size == null) return;

    _buildAndLoadBanner(size);
  }

  // ── Shared banner construction used by both load paths ─────
  void _buildAndLoadBanner(AdSize size) {
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
            _failedDueToNoInternet = false; // clear failure flag on success
          });
          debugPrint('Banner ad loaded ✅');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
          // Mark as failed so connectivity listener knows to retry
          _failedDueToNoInternet = true;
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdFreeCubit, AdFreeState>(
      builder: (context, adFreeState) {
        if (adFreeState.isAdFree) return const SizedBox.shrink();
        if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

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
