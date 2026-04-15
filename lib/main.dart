import 'dart:async';
import 'dart:ui';

import 'package:Spendara/repository/goal_repository.dart';
import 'package:Spendara/repository/transaction_repository.dart';
import 'package:Spendara/routes/app_routes.dart';
import 'package:Spendara/routes/route_generator.dart';
import 'package:Spendara/services/rewarded_ad_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'constants/constants.dart';
import 'core/crashlytics/crashlytics_keys.dart';
import 'core/di/injections.dart';
import 'core/theme/app_theme.dart';
import 'data/models/user_model.dart';
import 'features/ads/cubit/ad_free_cubit.dart';
import 'features/dashboard/cubit/dashboard_cubit.dart';
import 'features/goals/cubit/goal_cubit.dart';
import 'features/goals/model/goals_model.dart';
import 'features/insights/cubit/insights_cubit.dart';
import 'features/local/cubit/local_cubit.dart';
import 'features/transaction/cubit/transaction_cubit.dart';
import 'features/transaction/model/transaction_model.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint('${CrashlyticsKeys.appStartup}: $e');
        rethrow;
      }

      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          false,
        );
      } else {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
      }
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.log(
          '${CrashlyticsKeys.appStartup} | widget: ${errorDetails.library}',
        );
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.log(CrashlyticsKeys.appStartup);
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true; // must return true to mark as handled
      };
      try {
        await dotenv.load(fileName: ".env");
        await Hive.initFlutter();
        Hive.registerAdapter(TransactionModelAdapter());
        Hive.registerAdapter(GoalModelAdapter());
        Hive.registerAdapter(UserModelAdapter());
      } catch (e, s) {
        FirebaseCrashlytics.instance.log(CrashlyticsKeys.hiveInit);
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: CrashlyticsKeys.hiveAdapterRegister,
          fatal: true,
        );
        rethrow;
      }

      // ── 5. Hive box open ──────────────────────────────────────
      try {
        await TransactionRepository.init();
        await GoalRepository.init();
        await AdFreeCubit.init();
        await Hive.openBox<UserModel>(Constants.userBoxName);
        await Hive.openBox('settingsBox');
      } catch (e, s) {
        FirebaseCrashlytics.instance.log(CrashlyticsKeys.hiveBoxOpen);
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: CrashlyticsKeys.hiveBoxOpen,
          fatal: true,
        );
        rethrow;
      }

      // ── 6. DI setup ───────────────────────────────────────────
      try {
        setupDI();
      } catch (e, s) {
        FirebaseCrashlytics.instance.log(CrashlyticsKeys.diSetup);
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: CrashlyticsKeys.diSetup,
          fatal: true,
        );
        rethrow;
      }

      await Hive.openBox<UserModel>(Constants.userBoxName);
      await Hive.openBox('settingsBox');
      final box = Hive.box<UserModel>(Constants.userBoxName);
      final bool isOnboarded = box.get(Constants.userKey) != null;

      // ── 7. AdMob init ─────────────────────────────────────────
      try {
        await MobileAds.instance.initialize();
        RewardedAdService().loadAd();
      } catch (e, s) {
        // Non-fatal — app works without ads
        FirebaseCrashlytics.instance.log(CrashlyticsKeys.bannerAdLoad);
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: CrashlyticsKeys.bannerAdLoad,
          fatal: false, // ← false — ads failing ≠ app broken
        );
      }
      runApp(FinanceApp(isOnboarded: isOnboarded));
    },
    (error, stack) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.appStartup);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FinanceApp extends StatelessWidget {
  final bool isOnboarded;

  const FinanceApp({super.key, required this.isOnboarded});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionCubit>(
          create: (_) => getIt<TransactionCubit>()..load(),
        ),
        BlocProvider<GoalCubit>(create: (_) => getIt<GoalCubit>()..load()),
        BlocProvider<DashboardCubit>(
          create: (_) => getIt<DashboardCubit>()..load(),
        ),
        BlocProvider<InsightsCubit>(
          create: (_) => getIt<InsightsCubit>()..load(),
        ),
        BlocProvider(create: (_) => AdFreeCubit()..restore()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, local) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          locale: local,
          initialRoute: isOnboarded
              ? AppRoutes.appShell
              : AppRoutes.onBoardingScreen,
          onGenerateRoute: RouteGenerator.generateRoute,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('bn'),
            Locale('en'),
            Locale('es'),
            Locale('gu'),
            Locale('hi'),
            Locale('kn'),
            Locale('ml'),
            Locale('mr'),
            Locale('or'),
            Locale('pa'),
            Locale('ta'),
            Locale('te'),
            Locale('ur'),
            Locale('pt'),
            Locale('id'),
            Locale('ar'),
            Locale('fr'),
            Locale('ru'),
            Locale('tr'),
            Locale('vi'),
            Locale('th'),
            Locale('sw'),
          ],
        ),
      ),
    );
  }
}
