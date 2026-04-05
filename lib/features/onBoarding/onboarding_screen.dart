import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final box = Hive.box<UserModel>('userBox');
    await box.put(
      'current_user',
      UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      ),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  appLocalizations?.personaliseExperience ??
                      'Just a few details to personalise\nyour experience.',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                // ── Name Field ────────────────────────────────────────
                Text(
                  appLocalizations?.fullName ?? 'Full Name',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. John Doe',
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'e.g. you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return appLocalizations?.pleaseEnterEmail ??
                          'Please enter your email';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(val.trim())) {
                      return appLocalizations?.enterValidEmail ??
                          'Enter a valid email address';
                    }
                    return null;
                  },
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
                            color: Colors.white,
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
