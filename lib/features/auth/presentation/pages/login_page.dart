// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../bloc/auth_bloc.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _showSnackBar('Logged in successfully!');
            // Navigation handled by SplashPage listener or root router
          } else if (state is AuthError) {
            _showSnackBar('Login failed: ${state.message}');
          } else if (state is AuthEmailVerificationRequired) {
            _showSnackBar(
                'Sign up successful! Check your email for verification to complete login.');
          } else if (state is AuthUnauthenticated && state.message != null) {
            _showSnackBar(
                state.message!); // For potential messages like "User not found"
          }
        },
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthSignInRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ));
                          },
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthSignUpRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ));
                          },
                          child: const Text('Sign Up'),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage()));
                          },
                          child: const Text('Forgot Password?'),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const Text('OR'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthSignInWithOAuthRequested(
                                  provider: OAuthProvider.google,
                                ));
                          },
                          icon:
                              Image.asset('assets/google_logo.png', height: 24),
                          // Add asset
                          label: const Text('Sign In with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                        // Add other social login buttons here
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