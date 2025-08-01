// lib/features/settings/presentation/pages/settings_page.dart

import 'package:dadadu_app/core/locale/locale_cubit.dart';
import 'package:dadadu_app/core/theme/theme_cubit.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  // ✅ The local state for language is no longer needed.

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load non-cubit settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      });
    }
  }

  // Save a boolean setting
  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Helper to launch URLs safely
  Future<void> _launchURL(String url, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotLaunchUrl(url))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCubit = context.watch<ThemeCubit>();
    // ✅ Get the LocaleCubit from the context
    final localeCubit = context.watch<LocaleCubit>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSectionHeader(context, l10n.appearance),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.theme, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.light),
                          icon: const Icon(Icons.light_mode_rounded)),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.dark),
                          icon: const Icon(Icons.dark_mode_rounded)),
                      ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.system),
                          icon: const Icon(Icons.settings_suggest_rounded)),
                    ],
                    selected: {themeCubit.state},
                    onSelectionChanged: (newSelection) {
                      themeCubit.updateTheme(newSelection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.general),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_active_rounded,
                      color: theme.colorScheme.primary),
                  title: Text(l10n.pushNotifications,
                      style: theme.textTheme.titleMedium),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() => _notificationsEnabled = value);
                      _saveBoolSetting('notificationsEnabled', value);
                    },
                  ),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  // ✅ Get the subtitle from the cubit's state
                  subtitle: _getLanguageName(localeCubit.state),
                  // ✅ Pass the cubit to the dialog
                  onTap: () => _showLanguageDialog(context, localeCubit),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.privacy_tip_rounded,
                  title: l10n.privacySettings,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.support),
          Card(
            child: Column(
              children: [
                _buildNavigationTile(
                  context,
                  icon: Icons.help_center_rounded,
                  title: l10n.helpAndSupport,
                  onTap: () => _showHelpDialog(context),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.info_rounded,
                  title: l10n.aboutDadadu,
                  onTap: () => _launchURL('https://brosisus.com', context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.signOut),
            onPressed: () => _showSignOutDialog(context),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Helper to get the display name from a Locale
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 18, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => Divider(
      indent: 16,
      endIndent: 16,
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5));

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmSignOut),
          content: Text(l10n.areYouSureSignOut),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.helpAndSupport),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavigationTile(
                context,
                icon: Icons.gavel_rounded,
                title: l10n.privacyPolicy,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _launchURL('https://brosisus.com/privacy', context);
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                context,
                icon: Icons.delete_forever_rounded,
                title: l10n.deleteAccount,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _launchURL('https://brosisus.com/account/delete', context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  // ✅ UPDATED: Dialog now uses the LocaleCubit
  void _showLanguageDialog(BuildContext context, LocaleCubit localeCubit) {
    final l10n = AppLocalizations.of(context)!;
    final supportedLocales = {
      'English': const Locale('en'),
      'Français': const Locale('fr'),
      'Deutsch': const Locale('de'),
      'Español': const Locale('es'),
    };

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supportedLocales.length,
              itemBuilder: (context, index) {
                final languageName = supportedLocales.keys.elementAt(index);
                final locale = supportedLocales.values.elementAt(index);
                return RadioListTile<Locale>(
                  title: Text(languageName),
                  value: locale,
                  // Get the current value from the cubit's state
                  groupValue: localeCubit.state,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      // Call the cubit's method to update the state
                      localeCubit.updateLocale(value);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
