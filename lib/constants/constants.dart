import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class Constants {
  static const String userBoxName = 'userBox';
  static const String userKey = 'current_user';
  // ── EXPENSE CATEGORY KEYS ─────────────────────────────────
  // Grouped by parent for display — flat list for storage
  static const List<String> expenseCategoryKeys = [
    // 🍽 Food & Drinks
    'groceries',
    'food_delivery',
    'restaurants',
    'tea_snacks',
    // 🚗 Transport
    'fuel',
    'cab_auto',
    'public_transport',
    'vehicle_maintenance',
    // 🏠 Housing
    'rent',
    'electricity',
    'water_gas',
    'internet',
    'mobile_recharge',
    // 🛍 Shopping
    'online_shopping',
    'clothing',
    'electronics',
    // 💊 Health
    'medicine',
    'doctor',
    'gym_fitness',
    // 🎬 Entertainment
    'ott_subscriptions',
    'movies_events',
    // 📚 Education
    'tuition',
    'books_stationery',
    // 💰 Finance
    'emi',
    'insurance',
    // 🎁 Other
    'personal_care',
    'travel_vacation',
    'gifts_donations',
    'other',
  ];

  // ── INCOME CATEGORY KEYS ──────────────────────────────────
  static const List<String> incomeCategoryKeys = [
    'salary',
    'freelance',
    'business',
    'rental_income',
    'investment_returns',
    'bonus',
    'side_income',
    'gift_received',
    'refund_cashback',
    'other',
  ];

  // ── LEGACY KEY MAP ────────────────────────────────────────
  // Handles ALL old keys — both old English names AND old snake_keys
  static const Map<String, String> _legacyKeyMap = {
    // Old English display names → new keys
    'Food & Dining': 'food_delivery', // closest match
    'Transport': 'cab_auto',
    'Shopping': 'online_shopping',
    'Utilities': 'electricity',
    'Healthcare': 'medicine',
    'Entertainment': 'ott_subscriptions',
    'Education': 'tuition',
    'Other': 'other',
    'Salary': 'salary',
    'Freelance': 'freelance',
    'Investment': 'investment_returns',
    'Gift': 'gift_received',
    // Old snake_keys that changed
    'food_dining': 'food_delivery',
    'healthcare': 'medicine',
    'entertainment': 'ott_subscriptions',
    'investment': 'investment_returns',
    'gift': 'gift_received',
  };

  static String normalizeKey(String raw) => _legacyKeyMap[raw] ?? raw;

  // ── ICONS mapped by STORAGE KEY ──────────────────────────
  static const categoryIcons = <String, IconData>{
    // Food & Drinks
    'groceries': Icons.shopping_cart_outlined,
    'food_delivery': Icons.delivery_dining_outlined,
    'restaurants': Icons.restaurant_outlined,
    'tea_snacks': Icons.coffee_outlined,
    // Transport
    'fuel': Icons.local_gas_station_outlined,
    'cab_auto': Icons.directions_car_outlined,
    'public_transport': Icons.directions_bus_outlined,
    'vehicle_maintenance': Icons.build_outlined,
    // Housing
    'rent': Icons.home_outlined,
    'electricity': Icons.bolt_outlined,
    'water_gas': Icons.water_drop_outlined,
    'internet': Icons.wifi_outlined,
    'mobile_recharge': Icons.phone_android_outlined,
    // Shopping
    'online_shopping': Icons.shopping_bag_outlined,
    'clothing': Icons.checkroom_outlined,
    'electronics': Icons.devices_outlined,
    // Health
    'medicine': Icons.local_pharmacy_outlined,
    'doctor': Icons.medical_services_outlined,
    'gym_fitness': Icons.fitness_center_outlined,
    // Entertainment
    'ott_subscriptions': Icons.tv_outlined,
    'movies_events': Icons.movie_outlined,
    // Education
    'tuition': Icons.school_outlined,
    'books_stationery': Icons.menu_book_outlined,
    // Finance
    'emi': Icons.account_balance_outlined,
    'insurance': Icons.security_outlined,
    // Other
    'personal_care': Icons.face_outlined,
    'travel_vacation': Icons.flight_outlined,
    'gifts_donations': Icons.card_giftcard_outlined,
    'other': Icons.category_outlined,
    // Income
    'salary': Icons.account_balance_wallet_outlined,
    'freelance': Icons.work_outline,
    'business': Icons.store_outlined,
    'rental_income': Icons.house_outlined,
    'investment_returns': Icons.trending_up,
    'bonus': Icons.star_outline,
    'side_income': Icons.handyman_outlined,
    'gift_received': Icons.redeem_outlined,
    'refund_cashback': Icons.replay_outlined,
  };

  static IconData categoryIcon(String key) =>
      categoryIcons[normalizeKey(key)] ?? Icons.category_outlined;

  // ── CATEGORY GROUPS for UI display ───────────────────────
  // Used in Add/Edit screen to show grouped category picker
  static List<CategoryGroup> expenseCategoryGroups(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      CategoryGroup(
        label: l.categoryGroupFoodDrinks,
        icon: Icons.restaurant_menu_outlined,
        keys: ['groceries', 'food_delivery', 'restaurants', 'tea_snacks'],
        labels: [l.groceries, l.foodDelivery, l.restaurants, l.teaSnacks],
      ),
      CategoryGroup(
        label: l.categoryGroupTransport,
        icon: Icons.commute_outlined,
        keys: ['fuel', 'cab_auto', 'public_transport', 'vehicle_maintenance'],
        labels: [l.fuel, l.cabAuto, l.publicTransport, l.vehicleMaintenance],
      ),
      CategoryGroup(
        label: l.categoryGroupHousing,
        icon: Icons.home_outlined,
        keys: [
          'rent',
          'electricity',
          'water_gas',
          'internet',
          'mobile_recharge',
        ],
        labels: [
          l.rent,
          l.electricity,
          l.waterGas,
          l.internet,
          l.mobileRecharge,
        ],
      ),
      CategoryGroup(
        label: l.categoryGroupShopping,
        icon: Icons.shopping_bag_outlined,
        keys: ['online_shopping', 'clothing', 'electronics'],
        labels: [l.onlineShopping, l.clothing, l.electronics],
      ),
      CategoryGroup(
        label: l.categoryGroupHealth,
        icon: Icons.favorite_border_outlined,
        keys: ['medicine', 'doctor', 'gym_fitness'],
        labels: [l.medicine, l.doctor, l.gymFitness],
      ),
      CategoryGroup(
        label: l.categoryGroupEntertainment,
        icon: Icons.movie_outlined,
        keys: ['ott_subscriptions', 'movies_events'],
        labels: [l.ottSubscriptions, l.moviesEvents],
      ),
      CategoryGroup(
        label: l.categoryGroupEducation,
        icon: Icons.school_outlined,
        keys: ['tuition', 'books_stationery'],
        labels: [l.tuition, l.booksStationery],
      ),
      CategoryGroup(
        label: l.categoryGroupFinance,
        icon: Icons.account_balance_outlined,
        keys: ['emi', 'insurance'],
        labels: [l.emi, l.insurance],
      ),
      CategoryGroup(
        label: l.categoryGroupOther,
        icon: Icons.more_horiz,
        keys: ['personal_care', 'travel_vacation', 'gifts_donations', 'other'],
        labels: [l.personalCare, l.travelVacation, l.giftsDonations, l.other],
      ),
    ];
  }

  static List<CategoryGroup> incomeCategoryGroups(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      CategoryGroup(
        label: l.categoryGroupIncome,
        icon: Icons.account_balance_wallet_outlined,
        keys: [
          'salary',
          'freelance',
          'business',
          'rental_income',
          'investment_returns',
          'bonus',
          'side_income',
          'gift_received',
          'refund_cashback',
          'other',
        ],
        labels: [
          l.salary,
          l.freelance,
          l.business,
          l.rentalIncome,
          l.investmentReturns,
          l.bonus,
          l.sideIncome,
          l.giftReceived,
          l.refundCashback,
          l.other,
        ],
      ),
    ];
  }

  // ── FLAT LISTS (kept for backward compat) ─────────────────
  static List<String> expenseCategories(BuildContext context) =>
      expenseCategoryGroups(context).expand((g) => g.labels).toList();

  static List<String> incomeCategories(BuildContext context) =>
      incomeCategoryGroups(context).expand((g) => g.labels).toList();

  static List<String> weekDayLabels(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
  }

  static List<String> monthLabels(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      l.jan,
      l.feb,
      l.mar,
      l.apr,
      l.may,
      l.jun,
      l.jul,
      l.aug,
      l.sep,
      l.oct,
      l.nov,
      l.dec,
    ];
  }

  // ── KEY ↔ LABEL helpers ───────────────────────────────────
  static String categoryLabel(BuildContext context, String raw) {
    final key = normalizeKey(raw);
    // Check expense
    final ei = expenseCategoryKeys.indexOf(key);
    if (ei != -1) return expenseCategories(context)[ei];
    // Check income
    final ii = incomeCategoryKeys.indexOf(key);
    if (ii != -1) return incomeCategories(context)[ii];
    return raw;
  }

  // Convenience aliases kept for existing call sites
  static String expenseCategoryLabel(BuildContext context, String raw) =>
      categoryLabel(context, raw);

  static String incomeCategoryLabel(BuildContext context, String raw) =>
      categoryLabel(context, raw);

  static String expenseCategoryKey(BuildContext context, String label) {
    final idx = expenseCategories(context).indexOf(label);
    return idx != -1 ? expenseCategoryKeys[idx] : label;
  }

  static String incomeCategoryKey(BuildContext context, String label) {
    final idx = incomeCategories(context).indexOf(label);
    return idx != -1 ? incomeCategoryKeys[idx] : label;
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

// ── CategoryGroup model ───────────────────────────────────────
class CategoryGroup {
  final String label;
  final IconData icon;
  final List<String> keys;
  final List<String> labels;

  const CategoryGroup({
    required this.label,
    required this.icon,
    required this.keys,
    required this.labels,
  });
}
