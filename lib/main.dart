// lib/main.dart

import 'package:dadadu_app/core/routes/app_router.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/features/upload/presentation/pages/camera_screen.dart';
import 'package:dadadu_app/firebase_options.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'features/home/presentation/bloc/home_feed_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeCameras();

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final HomeFeedBloc _homeFeedBloc;
  late final ProfileBloc _profileBloc;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>();
    _homeFeedBloc = di.sl<HomeFeedBloc>();
    _profileBloc = di.sl<ProfileBloc>();

    debugPrint('MyApp: AuthBloc instance retrieved from DI.');
    debugPrint('MyApp: HomeFeedBloc instance retrieved from DI.');
    debugPrint('MyApp: ProfileBloc instance retrieved from DI.');

    _router = AppRouter.router(authBloc: _authBloc);
    debugPrint('MyApp: GoRouter initialized with AuthBloc.');

    _authBloc.add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    _homeFeedBloc.close();
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
        BlocProvider<AuthBloc>.value(
          value: _authBloc,
        ),
        BlocProvider<HomeFeedBloc>.value(
          value: _homeFeedBloc,
        ),
        BlocProvider<ProfileBloc>.value(
          value: _profileBloc,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false, // Set to false for production
        title: 'Dadadu App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: _router, // Use the configured GoRouter instance
      ),
    );
  }
}
