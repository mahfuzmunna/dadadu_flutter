// lib/main.dart

import 'dart:async';

import 'package:dadadu_app/core/routes/app_router.dart';
import 'package:dadadu_app/core/theme/theme_cubit.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/features/upload/presentation/pages/camera_screen.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeCameras();
    await Supabase.initialize(
      url: 'https://sqdqbmnqosfzhmrpbvqe.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZHFibW5xb3NmemhtcnBidnFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0NDUyODQsImV4cCI6MjA2ODAyMTI4NH0.O4SHLpBxaxKTXjyPiysYR4I57JXPS5LaBaktEbOY5IE',
      authOptions:
          const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );

    await di.init();

    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('FATAL APP STARTUP ERROR: $e');
    debugPrint('STACK TRACE: $stack');
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Stream subscription for deep links
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Provide the AuthBloc to the widget tree
    // This allows other widgets (like SignInPage, ProfilePage, etc.) to access it.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(
          create: (context) =>
              di.sl<AuthBloc>()..add(const AuthInitialCheckRequested()),
        ),
        BlocProvider(create: (context) => di.sl<FeedBloc>()),
        BlocProvider(create: (context) => di.sl<ProfileBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(builder: (context, themeMode) {
        final router = AppRouter.router(authBloc: context.watch<AuthBloc>());
        return Provider<GoRouter>.value(
          value: router,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            // Set to false for production
            title: 'Dadadu',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: router, // Use the configured GoRouter instance
          ),
        );
      }),
    );
  }
}
