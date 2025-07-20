// lib/core/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // For StreamSubscription

import 'package:dadadu_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:dadadu_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:dadadu_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:dadadu_app/features/home/presentation/pages/home_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/profile_page.dart';
import 'package:dadadu_app/core/pages/splash_page.dart';

import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import '../common/widgets/scaffold_with_navbar.dart';
// import 'package:dadadu_app/core/widgets/scaffold_with_navbar.dart';

// --- Placeholder Pages for new tabs (move to respective feature folders later) ---

class AppRouter {
  static GoRouter router({required AuthBloc authBloc}) {
    return GoRouter(
      routes: <RouteBase>[
        // --- Routes outside the ShellRoute (no bottom navigation) ---

        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const SplashPage();
          },
        ),
        GoRoute(
          path: '/signIn',
          builder: (BuildContext context, GoRouterState state) {
            return const SignInPage();
          },
        ),
        GoRoute(
          path: '/signUp',
          builder: (BuildContext context, GoRouterState state) {
            return const SignUpPage();
          },
        ),

        // --- ShellRoute for the main app content with a bottom navigation bar ---
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            // Branch 1: Home
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/home',
                  builder: (BuildContext context, GoRouterState state) {
                    return const HomePage();
                  },
                ),
              ],
            ),
            // Branch 2: Discover
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/discover',
                  builder: (BuildContext context, GoRouterState state) {
                    return const DiscoverPage(); // Placeholder
                  },
                ),
              ],
            ),
            // Branch 3: Upload
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/upload',
                  builder: (BuildContext context, GoRouterState state) {
                    return const UploadPage(); // Placeholder
                  },
                ),
              ],
            ),
            // Branch 4: Friends
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/friends',
                  builder: (BuildContext context, GoRouterState state) {
                    return const FriendsPage(); // Placeholder
                  },
                ),
              ],
            ),
            // Branch 5: Profile
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/profile',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ProfilePage();
                  },
                ),
              ],
            ),
          ],
        ),
      ],

      // --- Redirect Logic (Remains mostly the same, now accommodating new shell paths) ---
      redirect: (BuildContext context, GoRouterState state) {
        final AuthState authState = authBloc.state;
        final bool loggedIn = authState is Authenticated;
        final bool isAuthStatusChecking = authState is AuthInitial || authState is AuthLoading;

        final bool isAuthPath = state.uri.path == '/signIn' || state.uri.path == '/signUp';
        final bool isSplashPath = state.uri.path == '/';
        // Check if the current path is one of the valid shell paths
        final bool isWithinAppShell = state.uri.path.startsWith('/home') ||
            state.uri.path.startsWith('/discover') ||
            state.uri.path.startsWith('/upload') ||
            state.uri.path.startsWith('/friends') ||
            state.uri.path.startsWith('/profile');


        // 1. If authentication status is still being determined:
        if (isAuthStatusChecking) {
          return isSplashPath ? null : '/'; // Stay on splash, or go to splash
        }

        // 2. If authentication status has been determined:
        //    a. User is NOT logged in:
        if (!loggedIn) {
          // If trying to access protected content (not auth page or splash), redirect to signIn.
          // This includes any of the shell paths.
          return isAuthPath || isSplashPath ? null : '/signIn';
        }
        //    b. User IS logged in:
        else { // loggedIn is true
          // If trying to access splash or auth pages, redirect to home (default shell path).
          // Otherwise (already within the app shell), allow.
          return (isSplashPath || isAuthPath) ? '/home' : null;
        }
      },

      // Error builder for 404 pages
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.uri.path}'),
        ),
      ),

      // Listens to AuthBloc's stream to trigger redirects whenever auth state changes
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
    );
  }
}

// GoRouterRefreshStream remains the same
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}