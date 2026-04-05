import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ad_free_state.dart';

class AdFreeCubit extends Cubit<AdFreeState> {
  Timer? _countdownTimer;
  Timer? _expiryTimer;

  AdFreeCubit() : super(const AdFreeState());

  // ── Called when user earns reward ──────────────────────────────────
  void activateAdFree({int minutes = 60}) {
    // Cancel any existing timers
    _countdownTimer?.cancel();
    _expiryTimer?.cancel();

    final expiresAt = DateTime.now().add(Duration(minutes: minutes));
    emit(AdFreeState(isAdFree: true, expiresAt: expiresAt));

    // Tick every second → updates remaining time display
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.expiresAt != null &&
          DateTime.now().isBefore(state.expiresAt!)) {
        emit(state.copyWith()); // triggers rebuild for timer display
      }
    });

    // Auto-expire after 60 minutes
    _expiryTimer = Timer(Duration(minutes: minutes), _expireAdFree);
  }

  void _expireAdFree() {
    _countdownTimer?.cancel();
    emit(const AdFreeState(isAdFree: false));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _expiryTimer?.cancel();
    return super.close();
  }
}
