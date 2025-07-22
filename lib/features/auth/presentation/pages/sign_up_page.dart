// lib/features/auth/presentation/pages/sign_up_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart'; // Make sure auth_event.dart is part of auth_bloc.dart

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController =
      TextEditingController(); // NEW: Full Name Controller
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose(); // Dispose new controller
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _showSnackBar('Sign up successful! You are now logged in.');
            // This might happen if auto-login occurs after signup
            // Navigation handled by SplashPage listener or root router
          } else if (state is AuthEmailVerificationRequired) {
            _showSnackBar(
                'Sign up successful! Check your email for verification. You can now log in after verifying.');
            // Optionally navigate back to sign-in after successful signup requiring verification
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            _showSnackBar('Sign up failed: ${state.message}');
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
                  // App Logo at the top
                  Image.asset(
                    'assets/icons/logo_v2.png',
                    height: 120,
                  ),
                  const SizedBox(height: 48),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'your@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16), // NEW Field for Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16), // Username field remains
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Unique handle (e.g., @yourusername)',
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: const OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16), // Bio field remains
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio (Optional)',
                      hintText: 'Tell us about yourself',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
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
                              context.read<AuthBloc>().add(AuthSignUpRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    fullName:
                                        _fullNameController.text.trim().isEmpty
                                            ? null
                                            : _fullNameController.text.trim(),
                                    // Pass new field
                                    username:
                                        _usernameController.text.trim().isEmpty
                                            ? null
                                            : _usernameController.text.trim(),
                                    bio: _bioController.text.trim().isEmpty
                                        ? null
                                        : _bioController.text.trim(),
                                  ));
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Go back to SignInPage
                              },
                              child: const Text('Sign In'),
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