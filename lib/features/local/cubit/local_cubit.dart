import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _boxName = 'settingsBox';
  static const String _localeKey = 'selected_locale';
  static const _supportedCodes = [
    'bn',
    'en',
    'es',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'ta',
    'te',
    'ur',
    'pt',
    'id',
    'ar',
    'fr',
    'ru',
    'tr',
    'vi',
    'th',
    'sw',
  ];
  LocaleCubit() : super(_resolveInitialLocale());

  static Locale _resolveInitialLocale() {
    final box = Hive.box('settingsBox');

    // Priority 1: user's saved in-app choice
    final saved = box.get(_localeKey) as String?;
    if (saved != null && _supportedCodes.contains(saved)) {
      return Locale(saved);
    }

    // Priority 2: device language if supported
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (_supportedCodes.contains(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }

    // Priority 3: fallback
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    Hive.box(_boxName).put(_localeKey, locale.languageCode);
    emit(locale);
  }

  Future<void> changeLocale(Locale locale) async {
    final box = Hive.box(_boxName);
    await box.put(_localeKey, locale.languageCode);
    emit(locale);
  }
}
