/// Crashlytics log keys used across the app.
/// Pass these to FirebaseCrashlytics.instance.log() or
/// FirebaseCrashlytics.instance.recordError() to identify
/// exactly which part of the app an error originated from.

library;

class CrashlyticsKeys {
  CrashlyticsKeys._();

  // ──────────────────────────────────────────────────────────
  // APP INIT
  // ──────────────────────────────────────────────────────────

  static const String hiveInit = 'hive_init_failed';
  static const String hiveBoxOpen = 'hive_box_open_failed';
  static const String hiveAdapterRegister = 'hive_adapter_register_failed';
  static const String diSetup = 'dependency_injection_setup_failed';
  static const String appStartup = 'app_startup_failed';

  // ──────────────────────────────────────────────────────────
  // IN APP UPDATE
  static const String inAppUpdate = 'in_app_update_failed';

  // ──────────────────────────────────────────────────────────
  // ONBOARDING / PROFILE
  static const String onboardingSave = 'onboarding_save_failed';

  // ──────────────────────────────────────────────────────────
  // TRANSACTION REPOSITORY
  static const String transactionAdd = 'transaction_add_failed';
  static const String transactionUpdate = 'transaction_update_failed';
  static const String transactionDelete = 'transaction_delete_failed';
  static const String transactionFetchAll = 'transaction_fetch_all_failed';
  static const String transactionFetchById = 'transaction_fetch_by_id_failed';

  // ──────────────────────────────────────────────────────────
  // TRANSACTION CUBIT
  static const String transactionCubitLoad = 'transaction_cubit_load_failed';

  // ──────────────────────────────────────────────────────────
  // GOAL REPOSITORY
  static const String goalAdd = 'goal_add_failed';
  static const String goalUpdate = 'goal_update_failed';
  static const String goalDelete = 'goal_delete_failed';
  static const String goalFetchAll = 'goal_fetch_all_failed';

  // ──────────────────────────────────────────────────────────
  // GOAL CUBIT
  static const String goalCubitLoad = 'goal_cubit_load_failed';
  static const String goalCubitDeposit = 'goal_cubit_deposit_failed';

  // ──────────────────────────────────────────────────────────
  // DASHBOARD CUBIT
  static const String dashboardLoad = 'dashboard_load_failed';

  // ──────────────────────────────────────────────────────────
  // INSIGHTS CUBIT
  static const String insightsLoad = 'insights_load_failed';

  // ──────────────────────────────────────────────────────────
  // ADD / EDIT TRANSACTION SCREEN
  static const String addTransactionSave = 'add_transaction_screen_save_failed';
  static const String editTransactionSave =
      'edit_transaction_screen_save_failed';
  static const String deleteTransactionUI = 'delete_transaction_ui_failed';
  static const String datePickerOpen = 'date_picker_open_failed';

  // ──────────────────────────────────────────────────────────
  // ADS — BANNER
  static const String bannerAdLoad = 'banner_ad_load_failed';
  static const String bannerAdShow = 'banner_ad_show_failed';
  static const String bannerAdSizeNull = 'banner_ad_size_null';
  static const String bannerAdDispose = 'banner_ad_dispose_failed';
  static const String bannerAdRetry = 'banner_ad_retry_after_connectivity';

  // ──────────────────────────────────────────────────────────
  // ADS — REWARDED
  static const String rewardedAdLoad = 'rewarded_ad_load_failed';
  static const String rewardedAdFull = 'rewarded_ad_full_size_failed';
  static const String rewardedAdShow = 'rewarded_ad_show_failed';
  static const String adNotLoaded = 'rewarded_ad_not_loaded';

  // ──────────────────────────────────────────────────────────
  // SHARE / REFERRAL
  static const String shareApp = 'share_app_failed';
  static const String shareGoalAchievement = 'share_goal_achievement_failed';
  static const String shareMonthSummary = 'share_month_summary_failed';
  static const String referralTrackerRead = 'referral_tracker_read_failed';

  // ──────────────────────────────────────────────────────────
  // IN-APP REVIEW
  static const String inAppReviewRequest = 'in_app_review_request_failed';
  static const String inAppReviewCheck =
      'in_app_review_eligibility_check_failed';
}
