// lib/features/ads/cubit/ad_free_state.dart
part of 'ad_free_cubit.dart';

class AdFreeState {
  final bool isAdFree;
  final String remainingTime; // e.g. "47:23"

  const AdFreeState({this.isAdFree = false, this.remainingTime = ''});
}
