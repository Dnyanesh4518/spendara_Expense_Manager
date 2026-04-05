import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import '../../constants/ad_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../features/ads/cubit/ad_free_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../dashboard/cubit/dashboard_cubit.dart';
import '../local/cubit/local_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  // ── In-content banner ad ───────────────────────────────────────────
  BannerAd? _inContentAd;
  bool _inContentAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadInContentAd();
  }

  void _loadInContentAd() {
    final ad = BannerAd(
      // ✅ Medium Rectangle (300×250) — taller, better for in-content
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _inContentAd = ad as BannerAd;
            _inContentAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Profile in-content ad failed: $error');
          ad.dispose();
        },
      ),
    );
    ad.load();
  }

  void _showLanguagePicker() {
    final currentLocale = context.read<LocaleCubit>().state;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(ctx).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                children: [
                  const Icon(Icons.language_outlined),
                  const SizedBox(width: 12),
                  Text(
                    'Select Language',

                    /// Todo add localizations
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.35,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (_, index) {
                  final lang = _languages[index];
                  final isSelected = currentLocale.languageCode == lang.code;

                  return ListTile(
                    // leading: Text(
                    //   lang.flag,
                    //   style: const TextStyle(fontSize: 24),
                    // ),
                    title: Text(lang.nativeName),
                    subtitle: Text(lang.name),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(ctx).colorScheme.primary,
                          )
                        : null,
                    tileColor: isSelected
                        ? Theme.of(
                            ctx,
                          ).colorScheme.primary.withValues(alpha: 0.06)
                        : null,
                    onTap: () {
                      context.read<LocaleCubit>().changeLocale(
                        Locale(lang.code),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _inContentAd?.dispose();
    super.dispose();
  }

  void _loadUser() {
    final box = Hive.box<UserModel>('userBox');
    setState(() => _user = box.get('current_user'));
  }

  Future<void> _showEditDialog() async {
    final nameCtrl = TextEditingController(text: _user?.name);
    final emailCtrl = TextEditingController(text: _user?.email);
    final formKey = GlobalKey<FormState>();
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                appLocalizations?.editProfile ?? 'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: appLocalizations?.fullName ?? 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? appLocalizations?.nameRequired ?? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: appLocalizations?.emailAddress ?? 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return appLocalizations?.emailRequired ??
                        'Email is required';
                  }
                  if (!v.contains('@')) {
                    return appLocalizations?.enterValidEmail ??
                        'Enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final box = Hive.box<UserModel>('userBox');
                  final updated = UserModel(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                  );
                  await box.put('current_user', updated);
                  if (mounted) {
                    Navigator.pop(ctx);
                    context.read<DashboardCubit>().load();
                    _loadUser();
                  }
                },
                child: Text(appLocalizations?.saveChanges ?? 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = context.watch<LocaleCubit>().state;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    // Find current language display name
    final currentLang = _languages.firstWhere(
      (l) => l.code == currentLocale.languageCode,
      orElse: () => _languages.first,
    );
    final initials = _user?.name.isNotEmpty == true
        ? _user!.name
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations?.profile ?? 'Profile'),
        actions: [
          IconButton(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit_outlined),
            tooltip: appLocalizations?.editProfile ?? 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user?.name ?? '—',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(_user?.email ?? '—', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.person_outline_rounded,
              label: appLocalizations?.name ?? 'Name',
              value: _user?.name ?? '—',
            ),
            const SizedBox(height: 6),
            _InfoTile(
              icon: Icons.email_outlined,
              label: appLocalizations?.email ?? 'Email',
              value: _user?.email ?? '—',
            ),
            const SizedBox(height: 6),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.language_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Language',

                  /// TODO add localization for this
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                subtitle: Text(
                  currentLang.nativeName,
                  style: theme.textTheme.bodyLarge,
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: _showLanguagePicker, // ← opens language sheet
              ),
            ),

            const SizedBox(height: 18),

            // ── In-content Banner Ad (Medium Rectangle 300×250) ───────
            BlocBuilder<AdFreeCubit, AdFreeState>(
              builder: (context, adFreeState) {
                // Hide during ad-free period
                if (adFreeState.isAdFree) return const SizedBox.shrink();

                // Hide if not loaded
                if (!_inContentAdLoaded || _inContentAd == null) {
                  return const SizedBox.shrink();
                }

                return Center(
                  child: Container(
                    width: _inContentAd!.size.width.toDouble(),
                    height: _inContentAd!.size.height.toDouble(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AdWidget(ad: _inContentAd!),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.7),
          ),
        ),
        subtitle: Text(value, style: theme.textTheme.bodyLarge),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _Language {
  final String code;
  final String name;
  final String nativeName;

  const _Language(this.code, this.name, this.nativeName);
}

const List<_Language> _languages = [
  _Language('en', 'English', 'English'),
  _Language('hi', 'Hindi', 'हिन्दी'),
  _Language('mr', 'Marathi', 'मराठी'),
  _Language('ta', 'Tamil', 'தமிழ்'),
  _Language('te', 'Telugu', 'తెలుగు'),
  _Language('kn', 'Kannada', 'ಕನ್ನಡ'),
  _Language('bn', 'Bengali', 'বাংলা'),
  _Language('gu', 'Gujarati', 'ગુજરાતી'),
  _Language('ml', 'Malayalam', 'മലയാളം'),
  _Language('pa', 'Punjabi', 'ਪੰਜਾਬੀ'),
  _Language('es', 'Spanish', 'Español'),
  _Language('ur', 'Urdu', 'اردو'),
];
