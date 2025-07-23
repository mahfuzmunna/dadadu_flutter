// lib/core/routes/app_router.dart

import 'dart:async'; // For StreamSubscription

import 'package:dadadu_app/core/common/widgets/scaffold_with_nav_bar.dart'; // Ensure this path is correct
// Core imports
import 'package:dadadu_app/core/pages/splash_page.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart'; // Auth Bloc for redirection logic
// If you have a ForgotPasswordPage, make sure to import it too
import 'package:dadadu_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:dadadu_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:dadadu_app/features/auth/presentation/pages/upload_profile_photo_page.dart';
// import 'package:dadadu_app/features/auth/presentation/pages/sign_up_page_t.dart'; // No longer explicitly needed if LoginPage handles signup
import 'package:dadadu_app/features/discover/presentation/pages/discover_page.dart';
import 'package:dadadu_app/features/friends/presentation/pages/friends_page.dart';
import 'package:dadadu_app/features/home/presentation/pages/home_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/profile_page.dart';
import 'package:dadadu_app/features/settings/presentation/pages/settings_page.dart';
import 'package:dadadu_app/features/upload/presentation/pages/upload_page_s.dart'; // If you're using this
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/home_injection.dart' as di;
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/upload/presentation/pages/camera_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static GoRouter router({required AuthBloc authBloc}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      // The initial location for the router
      initialLocation: '/',
      debugLogDiagnostics: true,
      // Keep for debugging redirects

      routes: <RouteBase>[
        // --- Top-level Routes (no bottom navigation bar) ---

        GoRoute(
          path: '/',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/signUp',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
            path: '/upload-profile-photo',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const UploadProfilePhotoPage()),
        GoRoute(
            path: '/settings',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const SettingsPage()),

        GoRoute(
          path: '/camera',
          builder: (context, state) => const CameraScreen(),
        ),
        GoRoute(
          path: '/createPost',
          builder: (context, state) {
            final String? videoPath = state.extra as String?;
            if (videoPath == null) {
              return const Center(
                  child: Text('Error: No video path provided!'));
            }

            // return CreatePostPage(videoPath: videoPath); // Assuming you want CreatePostPage
            return UploadPage(
                videoPath: videoPath); // Or UploadPage, depending on your flow
          },
        ),
        GoRoute(
          path: '/editProfile',
          builder: (BuildContext context, GoRouterState state) =>
              const EditProfilePage(),
        ),

        // --- ShellRoute for the main app content with a bottom navigation bar ---
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            // Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            // Discover
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/discover',
                  builder: (context, state) => const DiscoverPage(),
                ),
              ],
            ),
            // Upload (Redirects to Camera)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/upload',
                  redirect: (context, state) => '/camera',
                ),
              ],
            ),
            // Friends
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/friends',
                  builder: (context, state) => const FriendsPage(),
                ),
              ],
            ),
            // Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (BuildContext context, GoRouterState state) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      // Pass the currently logged-in user to the ProfilePage
                      return ProfilePage(viewedUser: authState.user);
                    }
                    // Fallback or loading state if needed
                    return const Center(child: CircularProgressIndicator());
                  },
                  routes: [
                    // ✅ CORRECTED: Nested route for OTHER user profiles
                    GoRoute(
                      path: ':userId',
                      builder: (BuildContext context, GoRouterState state) {
                        final String userId = state.pathParameters['userId']!;

                        // Instead of fetching data here, we provide a ProfileBloc
                        // that will do the fetching for us.
                        return BlocProvider<ProfileBloc>(
                          create: (context) => di.sl<ProfileBloc>()
                            ..add(LoadUserProfile(userId: userId)),
                          // The ProfilePage now takes NO arguments for this route.
                          // It will get all its data from the ProfileBloc.
                          child: const ProfilePage(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],

      // --- GLOBAL REDIRECT LOGIC ---
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final currentLocation = state.uri.toString();

        if (authState is AuthInitial || authState is AuthLoading) {
          // While checking auth, always show the splash screen.
          return currentLocation == '/' ? null : '/';
        }

        if (authState is AuthSignUpSuccess) {
          return currentLocation == '/upload-profile-photo'
              ? null
              : '/upload-profile-photo';
        }

        // 2. Handle the initial loading state

        // 3. Handle the Authenticated state
        final isLoggedIn = authState is AuthAuthenticated;
        final isAuthRoute = currentLocation == '/login' ||
            currentLocation == '/signUp' ||
            currentLocation == '/forgot-password';
        if (isLoggedIn) {
          // If the user is logged in but on the splash or an auth route,
          // redirect them to the home page.
          if (currentLocation == '/' || isAuthRoute) {
            return '/home';
          }
        }
        // 4. Handle the Unauthenticated state
        else {
          // If the user is not logged in and is trying to access a protected route
          // (i.e., any route that ISN'T an auth route), redirect them to the login page.
          if (!isAuthRoute) {
            return '/login';
          }
        }
        if (authState is FirstRun && isLoggedIn) {
          return currentLocation == '/home' ? null : '/home';
        }

        // 5. No redirection needed
        // If none of the above conditions are met, the user is allowed to stay on the current page.
        // (e.g., logged in and on a protected page, or logged out and on an auth page).
        return null;
      },

      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(child: Text('Error: No route found for ${state.uri}')),
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