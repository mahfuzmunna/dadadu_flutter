// lib/features/auth/presentation/pages/now_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            _showSnackBar(context, 'You have been signed out.');
            // Navigation to login is handled by SplashPage or root router
          } else if (state is AuthError) {
            _showSnackBar(context, 'Error: ${state.message}');
          }
        },
        builder: (context, state) {
          UserEntity? user;
          bool isLoading = false;

          if (state is AuthAuthenticated) {
            user = state.user;
          } else if (state is AuthLoading) {
            isLoading = true;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else if (user != null) ...[
                  const Text('Welcome!', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  Text('User ID: ${user.id}'),
                  Text('Email: ${user.email ?? 'N/A'}'),
                  // Text(
                  //     'Email Confirmed: ${user.isEmailConfirmed ? 'Yes' : 'No'}'),
                  // Display other user data from UserEntity
                ] else ...[
                  const Text('Not logged in.', style: TextStyle(fontSize: 24)),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthSignOutRequested());
                        },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
