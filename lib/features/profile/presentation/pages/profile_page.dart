import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String? userName = "Guest";
    String? userEmail = "N/A";

    if (authState is Authenticated) {
      userName = authState.user.displayName ?? authState.user.email;
      userEmail = authState.user.email;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $userName!', style: const TextStyle(fontSize: 22)),
            if (userEmail != null) Text('Email: $userEmail'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}