// lib/features/ads/cubit/ad_free_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'ad_free_state.dart';

class AdFreeCubit extends Cubit<AdFreeState> {
  static const _boxName = 'settings';
  static const _expiryKey = 'ad_free_expiry';

  // UI-only ticker — just refreshes the countdown label every second
  // Does NOT control ad-free logic. Wall-clock timestamp does.
  Timer? _ticker;

  AdFreeCubit() : super(const AdFreeState());

  Box get _box => Hive.box(_boxName);

  // ── Call in main() before runApp ──────────────────────────
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // ── Call on app start to restore state if window still active
  void restore() {
    if (_isWindowActive) {
      _startTicker();
      emit(AdFreeState(isAdFree: true, remainingTime: _formatRemaining()));
    } else {
      // Window expired while app was closed — clean up
      _box.delete(_expiryKey);
      emit(const AdFreeState(isAdFree: false));
    }
  }

  void activateAdFree({required int minutes}) {
    final expiry = DateTime.now().add(Duration(minutes: minutes));
    _box.put(_expiryKey, expiry.toIso8601String());

    _startTicker();
    emit(AdFreeState(isAdFree: true, remainingTime: _formatRemaining()));
  }

  // ── Ticker — only for updating the UI label ───────────────
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isWindowActive) {
        // Window still open — update countdown label
        emit(AdFreeState(isAdFree: true, remainingTime: _formatRemaining()));
      } else {
        // Window expired — stop ticker, show ads again
        _ticker?.cancel();
        _box.delete(_expiryKey);
        emit(const AdFreeState(isAdFree: false));
      }
    });
  }

  // ── Reads wall-clock time from Hive — always correct ─────
  bool get _isWindowActive {
    final raw = _box.get(_expiryKey) as String?;
    if (raw == null) return false;
    final expiry = DateTime.tryParse(raw);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  Duration get _remaining {
    final raw = _box.get(_expiryKey) as String?;
    final expiry = DateTime.tryParse(raw ?? '');
    if (expiry == null) return Duration.zero;
    final diff = expiry.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  // Formats as "MM:SS" or "H:MM:SS"
  String _formatRemaining() {
    final d = _remaining;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
