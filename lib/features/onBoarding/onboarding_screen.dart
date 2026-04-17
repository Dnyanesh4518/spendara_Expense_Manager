import 'package:Spendara/core/analytics/analytics_keys.dart';
import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:Spendara/core/utils/email_validator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../screens/app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;
  EmailValidator emailValidator = EmailValidator();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final box = Hive.box<UserModel>('userBox');
      await box.put(
        'current_user',
        UserModel(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
      FirebaseAnalytics.instance.logEvent(
        name: '${AnalyticsKeys.userLoggedIn}_${_nameController.text.trim()}',
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AppShell(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.onboardingSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wallet_rounded,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Headline ──────────────────────────────────────────
                Text(
                  appLocalizations?.welcomeToExpenseTracker ??
                      'Welcome to\nExpenseTracker',
                  style: theme.textTheme.headlineLarge?.copyWith(height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  textAlign: TextAlign.center,
                  appLocalizations?.personaliseExperience ??
                      'Just a few details to personalise\nyour experience.',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name Field ────────────────────────────────────────
                    Text(
                      appLocalizations?.fullName ?? 'Full Name',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLength: 50,
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. John Doe',
                        hintStyle: theme.textTheme.bodySmall,
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return appLocalizations?.pleaseEnterName ??
                              'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Email Field ───────────────────────────────────────
                    Text(
                      appLocalizations?.emailAddress ?? 'Email Address',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLength: 50,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'e.g. you@example.com',
                        hintStyle: theme.textTheme.bodySmall,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (val) =>
                          emailValidator.validateEmail(val, appLocalizations),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── CTA Button ────────────────────────────────────────
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.barBackground,
                          ),
                        )
                      : Text(appLocalizations?.getStarted ?? 'Get Started'),
                ),
                const SizedBox(height: 16),

                // ── Privacy note ──────────────────────────────────────
                Center(
                  child: Text(
                    appLocalizations?.storedLocally ??
                        '🔒 Stored locally. We never share your data.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
