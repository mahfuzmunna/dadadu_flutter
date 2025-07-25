// lib/features/auth/presentation/pages/sign_in_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState; // Hide AuthState to avoid conflict with bloc

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
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showSnackBar('Login failed: ${state.message}');
          } else if (state is AuthUnauthenticated && state.message != null) {
            _showSnackBar(state.message!);
          }
        },
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              // More padding for Material 3 look
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo at the top
                  Image.asset(
                    'assets/icons/logo_v2.png',
                    // Replace with your actual logo path
                    height: 120, // Adjust size as needed
                  ),
                  const SizedBox(height: 48),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'your@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border:
                          OutlineInputBorder(), // Material 3 uses OutlineInputBorder by default
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
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
                          width: double.infinity, // Full width button
                          child: FilledButton(
                            // Material 3 FilledButton
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthSignInRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ));
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.push('/forgot-password');
                          },
                          child: const Text('Forgot Password?'),
                        ),
                        const SizedBox(height: 20),

                        Divider(
                          height: 40,
                          thickness: 1,
                          color: colorScheme.outlineVariant,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Text('OR',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            // OutlinedButton for social login
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthSignInWithOAuthRequested(
                                    provider: OAuthProvider.google,
                                  ));
                            },
                            icon: Image.asset('assets/google_logo.png',
                                height: 24),
                            label: const Text('Sign In with Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: colorScheme.onSurface,
                              side: BorderSide(color: colorScheme.outline),
                            ),
                          ),
                        ),
                        // Add other social login buttons here (e.g., Apple, Facebook)
                        const SizedBox(height: 32),

                        // Link to Sign Up Page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            TextButton(
                              onPressed: () {
                                context.push('/signUp');
                              },
                              child: const Text('Sign Up'),
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
