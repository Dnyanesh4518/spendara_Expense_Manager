import 'package:Spendara/repository/goal_repository.dart';
import 'package:Spendara/repository/transaction_repository.dart';
import 'package:Spendara/routes/app_routes.dart';
import 'package:Spendara/routes/route_generator.dart';
import 'package:Spendara/services/rewarded_ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
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

const String userBoxName = 'userBox';
const String userKey = 'current_user';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(GoalModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // Open boxes
  await TransactionRepository.init();
  await GoalRepository.init();

  setupDI();

  await Hive.openBox<UserModel>(userBoxName);
  await Hive.openBox('settingsBox');
  final box = Hive.box<UserModel>(userBoxName);
  final bool isOnboarded = box.get(userKey) != null;
  await MobileAds.instance.initialize();

  // ── test device Id Configuration ─────────────────────
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['980AD4B9BCA7E16C89DB348806A384D4']),
  );
  RewardedAdService().loadAd();
  runApp(FinanceApp(isOnboarded: isOnboarded));
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
        BlocProvider(create: (_) => AdFreeCubit()),
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
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (final supported in supportedLocales) {
              if (locale?.languageCode == supported.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },
        ),
      ),
    );
  }
}
