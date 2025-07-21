// lib/core/routes/app_router.dart

import 'dart:async'; // For StreamSubscription

import 'package:dadadu_app/core/common/widgets/scaffold_with_nav_bar.dart'; // Ensure this path is correct
// Core imports
import 'package:dadadu_app/core/pages/splash_page.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart'; // Auth Bloc for redirection logic
// Feature-specific page imports
import 'package:dadadu_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:dadadu_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:dadadu_app/features/discover/presentation/pages/discover_page.dart';
import 'package:dadadu_app/features/friends/presentation/pages/friends_page.dart';
import 'package:dadadu_app/features/home/presentation/pages/home_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/profile_page.dart';
import 'package:dadadu_app/features/upload/presentation/pages/camera_screen.dart';
import 'package:dadadu_app/features/upload/presentation/pages/create_post_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router({required AuthBloc authBloc}) {
    return GoRouter(
      // The initial location for the router
      initialLocation: '/',

      routes: <RouteBase>[
        // --- Routes that do NOT have the bottom navigation bar ---

        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const SplashPage(),
        ),
        GoRoute(
          path: '/signIn',
          builder: (BuildContext context, GoRouterState state) =>
              const SignInPage(),
        ),
        GoRoute(
          path: '/signUp',
          builder: (BuildContext context, GoRouterState state) =>
              const SignUpPage(),
        ),
        GoRoute(
          path: '/camera',
          builder: (BuildContext context, GoRouterState state) =>
              const CameraScreen(),
        ),
        GoRoute(
          path: '/createPost',
          builder: (BuildContext context, GoRouterState state) {
            final String videoPath =
                state.extra as String; // Cast extra to String
            return CreatePostPage(videoPath: videoPath);
          },
        ),
        GoRoute(
          path: '/editProfile',
          builder: (BuildContext context, GoRouterState state) =>
              const EditProfilePage(),
        ),

        // --- ShellRoute for the main app content with a bottom navigation bar ---
        // This is where the main navigation branches start.
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            // Branch 1: Home Tab
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/home',
                  builder: (BuildContext context, GoRouterState state) =>
                      const HomePage(),
                ),
              ],
            ),
            // Branch 2: Discover Tab
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/discover',
                  builder: (BuildContext context, GoRouterState state) =>
                      const DiscoverPage(),
                ),
              ],
            ),
            // Branch 3: Upload Tab (Redirects to Camera)
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/upload',
                  // This builder is effectively never reached due to the redirect
                  builder: (BuildContext context, GoRouterState state) => const Center(child: Text('Initiating Upload...')),
                  // Redirect from '/upload' (tab tap) directly to '/camera'
                  redirect: (context, state) => '/camera',
                ),
              ],
            ),
            // Branch 4: Friends Tab
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/friends',
                  builder: (BuildContext context, GoRouterState state) =>
                      const FriendsPage(),
                ),
              ],
            ),
            // Branch 5: Profile Tab
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/profile',
                  builder: (BuildContext context, GoRouterState state) =>
                      const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],

      // --- Global Redirect Logic based on Authentication State ---
      redirect: (BuildContext context, GoRouterState state) {
        final AuthState authState = authBloc.state;
        final bool loggedIn = authState is AuthAuthenticated;
        final bool isAuthStatusChecking = authState is AuthInitial || authState is AuthLoading;

        // Define specific path types
        final String currentPath = state.uri.path;
        final bool isSplashPath = currentPath == '/'; // <--- Defined here
        final bool isSignInPath = currentPath == '/signIn';
        final bool isSignUpPath = currentPath == '/signUp';

        // Define public paths (accessible without login or during login process)
        // Public paths are splash, sign-in, sign-up
        final bool isCurrentPathPublic =
            isSplashPath || isSignInPath || isSignUpPath;

        // Define paths that implicitly require authentication (camera and create post are part of post-login flow)
        // This includes all routes within the shell, plus direct routes like camera/createPost/editProfile
        final bool isCurrentPathInAppShell = currentPath.startsWith('/home') ||
            currentPath.startsWith('/discover') ||
            currentPath.startsWith('/upload') ||
            currentPath.startsWith('/friends') ||
            currentPath.startsWith('/profile');

        const List<String> protectedPathsOutsideShell = [
          '/camera',
          '/createPost',
          '/editProfile'
        ];
        final bool isCurrentPathProtectedOutsideShell =
            protectedPathsOutsideShell.contains(currentPath);

        final bool isCurrentPathProtected =
            isCurrentPathInAppShell || isCurrentPathProtectedOutsideShell;

        // --- Debugging Prints (helpful during development) ---
        debugPrint('--- GoRouter Redirect Check ---');
        debugPrint('Current Path: $currentPath');
        debugPrint('AuthBloc State: $authState');
        debugPrint('Logged In: $loggedIn');
        debugPrint('Is Auth Status Checking: $isAuthStatusChecking');
        debugPrint('Is Splash Path: $isSplashPath'); // Debug print
        debugPrint('Is Sign In Path: $isSignInPath'); // Debug print
        debugPrint('Is Sign Up Path: $isSignUpPath'); // Debug print
        debugPrint('Is Current Path Public: $isCurrentPathPublic');
        debugPrint('Is Current Path Protected: $isCurrentPathProtected');
        debugPrint('-----------------------------');

        // --- Redirect Logic ---

        // Rule 1: While authentication status is still being determined (Splash Screen)
        if (isAuthStatusChecking) {
          debugPrint('Status: Auth checking.');
          // Stay on splash page while checking auth status.
          // If trying to access any other route before check is done, go to splash.
          return isSplashPath ? null : '/';
        }

        // Rule 2: User IS Authenticated
        if (loggedIn) {
          debugPrint('Status: User authenticated.');
          // If on a public path (splash, sign-in, sign-up), redirect to home (default app start).
          if (isCurrentPathPublic) {
            debugPrint(
                'Result: Logged in, on public path. Redirecting to /home.');
            return '/home';
          }
          // Otherwise, allow to proceed to the current requested (protected) path.
          debugPrint('Result: Logged in, on protected path. Allow access.');
          return null;
        }

        // Rule 3: User is NOT Authenticated (and auth status check is complete)
        // This means authState is AuthUnauthenticated or AuthError (without a logged-in user).
        debugPrint('Status: User NOT authenticated (check complete).');
        // If on a sign-in or sign-up page, allow.
        if (isSignInPath || isSignUpPath) {
          debugPrint('Result: Not logged in, on auth path. Allow access.');
          return null;
        }
        // If on splash screen or any protected route, redirect to sign-in.
        debugPrint(
            'Result: Not logged in, on splash or protected path. Redirecting to /signIn.');
        return '/signIn';
      },

      // Error builder for 404 pages (route not found)
      errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Text('Error: Page not found at ${state.uri.path}'),
        ),
      ),

      // Listens to AuthBloc's stream to trigger redirects whenever auth state changes.
      // This is crucial for reacting to login/logout events.
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
    );
  }
}

/// A `Listenable` that notifies `GoRouter` when a `Stream` emits a new value.
/// Used to trigger re-evaluation of the router's `redirect` logic.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify listeners immediately on creation
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) =>
              notifyListeners(), // Notify listeners whenever the stream emits
        );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }
}