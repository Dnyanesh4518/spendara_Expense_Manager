import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/ads/cubit/ad_free_cubit.dart';
import '../services/rewarded_ad_service.dart';
import '../core/theme/app_colors.dart';

class RemoveAdsButton extends StatefulWidget {
  const RemoveAdsButton({super.key});

  @override
  State<RemoveAdsButton> createState() => _RemoveAdsButtonState();
}

class _RemoveAdsButtonState extends State<RemoveAdsButton> {
  final RewardedAdService _adService = RewardedAdService();

  @override
  void initState() {
    super.initState();
    _adService.loadAd(); // preload on widget creation
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  void _onTap() {
    _adService.showAd(
      onRewarded: () {
        // User watched full ad → activate ad-free
        context.read<AdFreeCubit>().activateAdFree(minutes: 60);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              spacing: 4,
              children: [
                const Icon(
                  Icons.celebration_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const Text('Ads removed for 1 hour! 🎉'),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      onNotLoaded: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not ready yet, please try again shortly.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AdFreeCubit, AdFreeState>(
      builder: (context, state) {
        // ── Active state: show countdown ──────────────────────────────
        if (state.isAdFree) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ad-free: ${state.remainingTime}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        // ── Default state: show button ────────────────────────────────
        return GestureDetector(
          onTap: _onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🚫Ads(1hr)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
