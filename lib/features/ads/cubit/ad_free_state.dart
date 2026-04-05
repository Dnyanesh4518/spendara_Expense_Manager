part of 'ad_free_cubit.dart';

class AdFreeState {
  final bool isAdFree;
  final DateTime? expiresAt;

  const AdFreeState({this.isAdFree = false, this.expiresAt});

  // Remaining time as readable string
  String get remainingTime {
    if (!isAdFree || expiresAt == null) return '';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return '';
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  AdFreeState copyWith({bool? isAdFree, DateTime? expiresAt}) => AdFreeState(
    isAdFree: isAdFree ?? this.isAdFree,
    expiresAt: expiresAt ?? this.expiresAt,
  );
}
