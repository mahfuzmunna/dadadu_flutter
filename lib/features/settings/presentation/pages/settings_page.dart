// lib/features/settings/presentation/pages/settings_page.dart

import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Example Settings Tile
          ListTile(
            leading: Icon(Icons.privacy_tip_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: Text('Privacy Settings',
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Privacy Settings')),
              );
              // context.push('/settings/privacy'); // Example navigation
            },
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.5)),
          ListTile(
            leading: Icon(Icons.notifications_active_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: Text('Notification Preferences',
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Navigate to Notification Preferences')),
              );
              // context.push('/settings/notifications'); // Example navigation
            },
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.5)),
          ListTile(
            leading: Icon(Icons.help_center_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: Text('Help & Support',
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Help & Support')),
              );
              // context.push('/settings/help'); // Example navigation
            },
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.5)),
          ListTile(
            leading: Icon(Icons.info_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: Text('About Dadadu App',
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to About page')),
              );
              // context.push('/settings/about'); // Example navigation
            },
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.5)),
          const SizedBox(height: 32),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              onPressed: () {
                // Confirm action before signing out
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Confirm Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Dismiss dialog
                          },
                          child: Text('Cancel',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Dismiss dialog
                            // Dispatch Sign Out event
                            context
                                .read<AuthBloc>()
                                .add(const AuthSignOutRequested());
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor:
                                Theme.of(context).colorScheme.onError,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .error, // Error color for sign out
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
