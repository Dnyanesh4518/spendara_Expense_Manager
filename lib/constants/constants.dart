import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class Constants {
  static const List<String> expenseCategoryKeys = [
    'food_dining',
    'transport',
    'shopping',
    'utilities',
    'healthcare',
    'entertainment',
    'education',
    'other',
  ];

  static const List<String> incomeCategoryKeys = [
    'salary',
    'freelance',
    'investment',
    'gift',
    'other',
  ];

  // ── Old English names → storage key migration map ────────
  // Handles transactions saved BEFORE the key refactor
  static const Map<String, String> _legacyKeyMap = {
    'Food & Dining': 'food_dining',
    'Transport': 'transport',
    'Shopping': 'shopping',
    'Utilities': 'utilities',
    'Healthcare': 'healthcare',
    'Entertainment': 'entertainment',
    'Education': 'education',
    'Other': 'other',
    'Salary': 'salary',
    'Freelance': 'freelance',
    'Investment': 'investment',
    'Gift': 'gift',
  };

  /// Normalizes any key — handles both new keys and old English names
  static String normalizeKey(String raw) => _legacyKeyMap[raw] ?? raw;

  // ── Icons mapped by STORAGE KEY ──────────────────────────
  static const categoryIcons = <String, IconData>{
    'food_dining': Icons.restaurant_outlined,
    'transport': Icons.directions_car_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'utilities': Icons.bolt_outlined,
    'healthcare': Icons.local_pharmacy_outlined,
    'entertainment': Icons.movie_outlined,
    'education': Icons.school_outlined,
    'salary': Icons.account_balance_wallet_outlined,
    'freelance': Icons.work_outline,
    'investment': Icons.trending_up,
    'gift': Icons.card_giftcard_outlined,
    'other': Icons.category_outlined,
  };

  static IconData categoryIcon(String key) =>
      categoryIcons[normalizeKey(key)] ?? Icons.category_outlined;

  // ── Localized label lists ────────────────────────────────
  static List<String> expenseCategories(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      l.foodAndDining,
      l.transport,
      l.shopping,
      l.utilities,
      l.healthcare,
      l.entertainment,
      l.education,
      l.other,
    ];
  }

  static List<String> incomeCategories(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [l.salary, l.freelance, l.investment, l.gift, l.other];
  }

  static List<String> weekDayLabels(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
  }

  // ── KEY → LABEL (handles both new keys and old English names)
  static String expenseCategoryLabel(BuildContext context, String raw) {
    final key = normalizeKey(raw); // 'Food & Dining' → 'food_dining'
    final index = expenseCategoryKeys.indexOf(key);
    return index != -1
        ? expenseCategories(context)[index] // ✅ localized
        : raw; // unknown key — show as-is
  }

  static String incomeCategoryLabel(BuildContext context, String raw) {
    final key = normalizeKey(raw);
    final index = incomeCategoryKeys.indexOf(key);
    return index != -1 ? incomeCategories(context)[index] : raw;
  }

  // ── LABEL → KEY ──────────────────────────────────────────
  static String expenseCategoryKey(BuildContext context, String label) {
    final index = expenseCategories(context).indexOf(label);
    return index != -1 ? expenseCategoryKeys[index] : label;
  }

  static String incomeCategoryKey(BuildContext context, String label) {
    final index = incomeCategories(context).indexOf(label);
    return index != -1 ? incomeCategoryKeys[index] : label;
  }

  // ── Goal icons (unchanged) ───────────────────────────────
  static const goalIcons = <String, IconData>{
    'shield': Icons.shield_outlined,
    'flight': Icons.flight_outlined,
    'laptop': Icons.laptop_outlined,
    'favorite': Icons.favorite_outline,
    'home': Icons.home_outlined,
    'car': Icons.directions_car_outlined,
    'savings': Icons.savings_outlined,
  };

  static IconData goalIcon(String name) =>
      goalIcons[name] ?? Icons.flag_outlined;

  static List<Color> get goalColors => AppColors.categoryColors;
}
