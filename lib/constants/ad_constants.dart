import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdConstants {
  AdConstants._();
  static String bannerADId =
      dotenv.env['BANNER_AD_CONSTANT'] ??
      'ca-app-pub-3940256099942544/6300978111';
  static String rewardedADId =
      dotenv.env['REWARDED_AD_CONSTANT'] ??
      'ca-app-pub-3940256099942544/6300978111';
  static const bool _isTesting = true;

  /// TODO change in production release

  // ── Banner AD
  static String get bannerAdUnitId {
    if (_isTesting) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Google test ID
    }
    return bannerADId; // banner ID
  }

  // ── Rewarded AD
  static String get rewardedAdUnitId {
    return rewardedADId; // rewarded ID
  }
}
