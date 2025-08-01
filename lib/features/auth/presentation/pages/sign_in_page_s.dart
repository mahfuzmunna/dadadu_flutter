// lib/features/auth/presentation/pages/sign_in_page.dart

import 'package:dadadu_app/core/locale/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ✅ NEW: Helper widget for the language selection menu
  Widget _buildLanguageSelector(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();
    // Map of display names to Locale objects
    const supportedLocales = {
      'English': Locale('en'),
      'Français': Locale('fr'),
      'Deutsch': Locale('de'),
      'Español': Locale('es'),
    };

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language_rounded),
      tooltip: 'Select Language',
      onSelected: (Locale locale) {
        // Call the cubit's method to update the app's language
        localeCubit.updateLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return supportedLocales.entries.map((entry) {
          return PopupMenuItem<Locale>(
            value: entry.value,
            child: Text(entry.key),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        centerTitle: true,
        // ✅ Add the language selector to the AppBar actions
        actions: [
          _buildLanguageSelector(context),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Use the translated string with a placeholder
            _showSnackBar(l10n.loginFailed(state.message));
          } else if (state is AuthUnauthenticated && state.message != null) {
            _showSnackBar(state.message!);
          }
        },
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/logo_v2.png',
                    height: 120,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      hintText: l10n.emailHint,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      hintText: l10n.passwordHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthSignInRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ));
                            },
                            child: Text(l10n.signIn),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.push('/forgot-password');
                          },
                          child: Text(l10n.forgotPassword),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          height: 40,
                          thickness: 1,
                          color: colorScheme.outlineVariant,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Text(l10n.or,
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthSignInWithOAuthRequested(
                                    provider: OAuthProvider.google,
                                  ));
                            },
                            icon: Image.asset('assets/google_logo.png',
                                height: 24),
                            label: Text(l10n.signInWithGoogle),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.dontHaveAnAccount,
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            TextButton(
                              onPressed: () {
                                context.push('/signUp');
                              },
                              child: Text(l10n.signUp),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
