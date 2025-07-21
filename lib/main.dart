// lib/main.dart

import 'package:dadadu_app/features/upload/presentation/pages/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dadadu_app/firebase_options.dart';
import 'package:dadadu_app/core/routes/app_router.dart';
import 'package:dadadu_app/core/theme/app_theme.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;

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
        BlocProvider<HomeFeedBloc>( // Provide HomeFeedBloc here
          create: (context) {
            try {
              final bloc = di.sl<HomeFeedBloc>();
              debugPrint('HomeFeedBloc created by Root Provider!'); // Debug message
              return bloc;
            } catch (e) {
              // Log any error during GetIt retrieval
              debugPrint('ERROR in main.dart: Failed to create HomeFeedBloc from GetIt: $e');
              rethrow; // Re-throw to see the original error if GetIt fails
            }
          },
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