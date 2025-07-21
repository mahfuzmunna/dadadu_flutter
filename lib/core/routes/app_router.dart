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
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/upload/presentation/pages/camera_screen.dart';
import '../../features/upload/presentation/pages/create_post_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import '../common/widgets/scaffold_with_nav_bar.dart';
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
        // NEW CAMERA ROUTE
        GoRoute(
          path: '/camera',
          builder: (BuildContext context, GoRouterState state) {
            return const CameraScreen();
          },
        ),
        // NEW CREATE POST ROUTE
        GoRoute(
          path: '/createPost',
          builder: (BuildContext context, GoRouterState state) {
            // Retrieve the videoPath passed as an extra
            final String videoPath = state.extra as String;
            return CreatePostPage(videoPath: videoPath);
          },
        ),
        // Inside AppRouter.router's routes list:
        GoRoute(
          path: '/editProfile', // <-- This path must match exactly with context.push()
          builder: (BuildContext context, GoRouterState state) {
            return const EditProfilePage(); // <-- Ensure you're returning EditProfilePage
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
              // Update this branch to navigate to /camera when /upload is tapped
              routes: <RouteBase>[
                GoRoute(
                  path: '/upload',
                  // Builder returns a simple placeholder as the actual upload flow starts on a different route
                  builder: (BuildContext context, GoRouterState state) => const Center(child: Text('Initiating Upload...')),
                  // We use a redirect here to immediately go to the camera screen
                  redirect: (context, state) {
                    // This redirect will trigger when the bottom nav bar item for /upload is tapped.
                    // It ensures that /upload directly leads to the /camera screen.
                    return '/camera';
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
        final bool isCameraPath = state.uri.path == '/camera'; // Camera needs permissions, not necessarily logged in *yet* but usually part of post-login flow
        final bool isCreatePostPath = state.uri.path == '/createPost'; // Post creation clearly requires being logged in

        print('--- GoRouter Redirect Debug ---');
        print('Current Path: ${state.uri.path}');
        print('AuthBloc State: $authState');
        print('Logged In: $loggedIn');
        print('Is Auth Path: $isAuthPath');
        print('Is Splash Path: $isSplashPath');
        print('Is Camera Path: $isCameraPath'); // New debug
        print('Is Create Post Path: $isCreatePostPath'); // New debug
        // Check if the current path is one of the valid shell paths

        // final bool isWithinAppShell = state.uri.path.startsWith('/home') ||
        //     state.uri.path.startsWith('/discover') ||
        //     state.uri.path.startsWith('/upload') ||
        //     state.uri.path.startsWith('/friends') ||
        //     state.uri.path.startsWith('/profile');


        // 1. If authentication status is still being determined:
        if (!loggedIn) {
          print('Redirect Reason: User NOT logged in.');
          // If trying to access protected content (not auth page, splash, camera, or create post), redirect to signIn.
          // Note: Camera and CreatePost *should* be protected, but for initial flow they are direct routes.
          // You might want to adjust this to redirect camera/createPost to signIn if user tries to directly access them without being logged in.
          // For now, they are treated as non-protected by the router's redirect unless coming from a protected path.
          final bool isPublicPath = isAuthPath || isSplashPath; // || isCameraPath || isCreatePostPath; // Consider making camera/createPost protected after user logs in.

          if (isPublicPath) {
            print('Result: Stay on current (Auth/Splash) path.');
            return null;
          } else {
            print('Result: Redirecting to /signIn from protected path.');
            return '/signIn';
          }
        } else { // loggedIn is true
          print('Redirect Reason: User IS logged in.');
          // If trying to access splash or auth pages, redirect to home (default shell path).
          // Otherwise (already within the app shell, or on camera/createPost), allow.
          if (isSplashPath || isAuthPath) {
            print('Result: Redirecting to /home (logged in, on auth/splash).');
            return '/home';
          } else {
            print('Result: Stay on current (protected) path or new feature path.');
            return null;
          }
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