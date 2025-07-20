// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dadadu_app/firebase_options.dart';
import 'package:dadadu_app/core/routes/app_router.dart';
import 'package:dadadu_app/core/theme/app_theme.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await di.init();

    runApp(const MyApp());
  } catch (e, stack) {
    print('FATAL APP STARTUP ERROR: $e');
    print('STACK TRACE: $stack');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'App failed to start.\nCheck console for details.\nError: ${e.toString()}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
          lazy: false,
        ),
      ],
      child: Builder(
        builder: (context) {
          // Get the AuthBloc instance from the widget tree
          final AuthBloc authBloc = context.read<AuthBloc>();

          return MaterialApp.router(
            title: 'Dadadu App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // CALL AppRouter.router and pass the authBloc instance
            routerConfig: AppRouter.router(authBloc: authBloc),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}