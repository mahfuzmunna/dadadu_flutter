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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/locale/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
    debugPrint('FATAL APP STARTUP ERROR: $e,$stack');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(const AuthInitialCheckRequested());
    _router =
        AppRouter.router(authBloc: _authBloc); // 👈 Static router instance
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (context) => LocaleCubit()),
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider(create: (_) => di.sl<FeedBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return Provider<GoRouter>.value(
            value: _router,
            child: BlocBuilder<LocaleCubit, Locale>(builder: (context, locale) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Dadadu',
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: _router, // 🚀 Stable router
              );
            }),
          );
        },
      ),
    );
  }
}