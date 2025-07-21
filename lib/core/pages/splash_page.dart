// lib/core/pages/splash_page.dart

import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:dadadu_app/features/auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>( // Listen to AuthBloc state changes
        listener: (context, state) {
          // This listener will only trigger when the state *changes*
          // from AuthInitial/AuthLoading to Authenticated/Unauthenticated.
          if (state is AuthAuthenticated) {
            // User is authenticated, go to the home screen (which is part of the shell route)
            context.go('/home');
          } else if (state is AuthUnauthenticated) {
            // User is not authenticated, go to the sign-in page
            context.go('/signIn');
          }
          // AuthInitial and AuthLoading states mean we're still checking, so do nothing.
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Your app logo or icon
                Icon(
                  Icons.videocam, // Example icon, replace with your app's logo
                  size: 100,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Dadadu App',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // Show a progress indicator while checking auth status
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthInitial || state is AuthLoading) {
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary),
                      );
                    }
                    return const SizedBox.shrink(); // Hide after status is known
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}