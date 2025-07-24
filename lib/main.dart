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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Stream subscription for deep links
  StreamSubscription? _sub;
  late final AuthBloc _authBloc;
  late final FeedBloc _postBloc;
  late final ProfileBloc _profileBloc;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>();
    _postBloc = di.sl<FeedBloc>();
    _profileBloc = di.sl<ProfileBloc>();

    debugPrint('MyApp: AuthBloc instance retrieved from DI.');
    debugPrint('MyApp: HomeFeedBloc instance retrieved from DI.');
    debugPrint('MyApp: ProfileBloc instance retrieved from DI.');

    _router = AppRouter.router(authBloc: _authBloc);
    debugPrint('MyApp: GoRouter initialized with AuthBloc.');

    _authBloc.add(const AuthInitialCheckRequested());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authBloc.close();
    _postBloc.close();
    _profileBloc.close();
    debugPrint('MyApp: AuthBloc disposed.');
    debugPrint('MyApp: AuthBloc, HomeFeedBloc and ProfileBloc disposed.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Provide the AuthBloc to the widget tree
    // This allows other widgets (like SignInPage, ProfilePage, etc.) to access it.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider<AuthBloc>.value(
          value: _authBloc,
        ),
        BlocProvider<FeedBloc>.value(
          value: _postBloc,
        ),
        BlocProvider<ProfileBloc>.value(
          value: _profileBloc,
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(builder: (context, themeMode) {
        final GoRouter router = _router;
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          // Set to false for production
          title: 'Dadadu App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: _router, // Use the configured GoRouter instance
        );
      }),
    );
  }
}
