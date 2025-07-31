// lib/features/settings/presentation/pages/settings_page.dart

import 'package:dadadu_app/core/theme/theme_cubit.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // ❗️ Add url_launcher to your pubspec.yaml

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English'; // Local state for language

  // Helper to launch URLs safely
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Show an error snackbar if the URL can't be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCubit = context.watch<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_rounded)),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_rounded)),
                      ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_suggest_rounded)),
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
          _buildSectionHeader(context, 'General'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_active_rounded,
                      color: theme.colorScheme.primary),
                  title: Text('Push Notifications',
                      style: theme.textTheme.titleMedium),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                _buildDivider(),
                // ✅ Language Selector Tile
                _buildNavigationTile(
                  context,
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: _selectedLanguage, // Show the current language
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Support'),
          Card(
            child: Column(
              children: [
                // ✅ Help & Support now opens a dialog
                _buildNavigationTile(
                  context,
                  icon: Icons.help_center_rounded,
                  title: 'Help & Support',
                  onTap: () => _showHelpDialog(context),
                ),
                _buildDivider(),
                // ✅ About now opens a web link
                _buildNavigationTile(
                  context,
                  icon: Icons.info_rounded,
                  title: 'About Dadadu',
                  onTap: () => _launchURL('https://brosisus.com'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
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

  // ✅ Updated to include an optional subtitle
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: Dialog for Help & Support
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavigationTile(
                context,
                icon: Icons.gavel_rounded,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _launchURL('https://brosisus.com/privacy');
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                context,
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _launchURL('https://brosisus.com/account/delete');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: Dialog for Language Selection
  void _showLanguageDialog(BuildContext context) {
    final languages = ['English', 'Français', 'Deutsch', 'Español'];
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                        // TODO: Add logic to persist language setting
                      });
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
