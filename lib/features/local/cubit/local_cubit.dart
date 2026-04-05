import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _boxName = 'settingsBox';
  static const String _localeKey = 'selected_locale';

  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final box = Hive.box(_boxName);
    final saved = box.get(_localeKey, defaultValue: 'en') as String;
    emit(Locale(saved));
  }

  Future<void> changeLocale(Locale locale) async {
    final box = Hive.box(_boxName);
    await box.put(_localeKey, locale.languageCode);
    emit(locale);
  }
}
