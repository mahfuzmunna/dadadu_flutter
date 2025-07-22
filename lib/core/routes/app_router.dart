// lib/core/routes/app_router.dart

import 'dart:async'; // For StreamSubscription

import 'package:dadadu_app/core/common/widgets/scaffold_with_nav_bar.dart'; // Ensure this path is correct
// Core imports
import 'package:dadadu_app/core/pages/splash_page.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'; // Needed for ProfilePage viewedUser
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart'; // Auth Bloc for redirection logic
// If you have a ForgotPasswordPage, make sure to import it too
import 'package:dadadu_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:dadadu_app/features/auth/presentation/pages/sign_in_page.dart';
// import 'package:dadadu_app/features/auth/presentation/pages/sign_up_page.dart'; // No longer explicitly needed if LoginPage handles signup
import 'package:dadadu_app/features/discover/presentation/pages/discover_page.dart';
import 'package:dadadu_app/features/friends/presentation/pages/friends_page.dart';
import 'package:dadadu_app/features/home/presentation/pages/home_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/profile_page.dart';
import 'package:dadadu_app/features/settings/presentation/pages/settings_page.dart';
import 'package:dadadu_app/features/upload/presentation/pages/upload_page_t.dart'; // If you're using this
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/upload/presentation/pages/camera_screen.dart';

class AppRouter {
  static GoRouter router({required AuthBloc authBloc}) {
    return GoRouter(
      // The initial location for the router
      initialLocation: '/',
      debugLogDiagnostics: true,
      // Keep for debugging redirects

      routes: <RouteBase>[
        // --- Top-level Routes (no bottom navigation bar) ---

        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const SplashPage(),
        ),
        // Unified login/signup page route
        GoRoute(
          path: '/login', // Changed from /signIn to /login for consistency
          builder: (BuildContext context, GoRouterState state) =>
              const SignInPage(),
        ),
        // Removed explicit /signUp route if LoginPage handles both.
        // If you still have a separate SignUpPage, keep its route here.
        GoRoute(
          path: '/signUp',
          builder: (BuildContext context, GoRouterState state) =>
              const SignUpPage(),
        ),
        GoRoute(
          path: '/forgot-password', // Route for password reset
          builder: (BuildContext context, GoRouterState state) =>
              const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/camera',
          builder: (BuildContext context, GoRouterState state) =>
              const CameraScreen(),
        ),
        GoRoute(
          path: '/createPost',
          builder: (BuildContext context, GoRouterState state) {
            final String? videoPath = state.extra as String?;
            if (videoPath == null) {
              return const Center(
                  child: Text('Error: No video path provided!'));
            }
            // return CreatePostPage(videoPath: videoPath); // Assuming you want CreatePostPage
            return const UploadPage(); // Or UploadPage, depending on your flow
          },
        ),
        GoRoute(
          path: '/editProfile',
          builder: (BuildContext context, GoRouterState state) =>
              const EditProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) =>
              const SettingsPage(),
        ),

        // --- ShellRoute for the main app content with a bottom navigation bar ---
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
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
                  builder: (BuildContext context, GoRouterState state) =>
                      const Center(child: Text('Initiating Upload...')),
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
                      const ProfilePage(), // Displays current user's profile
                  routes: [
                    // Nested route for other user profiles: /profile/:userId
                    GoRoute(
                      path: ':userId',
                      builder: (BuildContext context, GoRouterState state) {
                        final String userId = state.pathParameters['userId']!;
                        // TODO: Implement actual user fetching logic here based on userId.
                        // This is a placeholder for fetching another user's profile data.
                        // Ensure your UserEntity matches what you expect
                        final UserEntity dummyOtherUser = UserEntity(
                          uid: userId,
                          // Use 'id' for consistency with UserEntity
                          email: 'user$userId@example.com',
                          isEmailConfirmed: true,
                          createdAt: DateTime.now().toString(),
                          // Add other properties as needed by your UserEntity
                          // e.g., username, profilePhotoUrl if they are part of UserEntity
                        );
                        return ProfilePage(
                            viewedUser:
                                dummyOtherUser); // Pass the fetched/dummy user
                      },
                    ),
                  ],
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
        final bool isAuthStatusChecking =
            authState is AuthInitial || authState is AuthLoading;

        final String currentPath = state.uri.path;
        final bool isSplashPath = currentPath == '/';
        final bool isLoginPagePath = currentPath == '/login'; // Use /login
        final bool isForgotPasswordPath =
            currentPath == '/forgot-password'; // Check for forgot password path

        // Define public paths that do NOT require authentication
        const List<String> publicPaths = [
          '/',
          '/login',
          '/forgot-password'
        ]; // Include /forgot-password
        final bool isCurrentPathPublic = publicPaths.contains(currentPath);

        // Define paths that require authentication (any path not public)
        final bool isCurrentPathProtected = !isCurrentPathPublic;

        // --- Debugging Prints (helpful during development) ---
        debugPrint('--- GoRouter Redirect Check ---');
        debugPrint('Current Path: $currentPath');
        debugPrint('AuthBloc State: $authState');
        debugPrint('Logged In: $loggedIn');
        debugPrint('Is Auth Status Checking: $isAuthStatusChecking');
        debugPrint('Is Current Path Public: $isCurrentPathPublic');
        debugPrint('Is Current Path Protected: $isCurrentPathProtected');
        debugPrint('-----------------------------');

        // --- Redirect Logic ---

        // Rule 1: While authentication status is still being determined (Splash Screen)
        if (isAuthStatusChecking) {
          debugPrint('Status: Auth checking.');
          // Stay on splash page while checking auth status.
          // If trying to access any other route before check is done, redirect to splash.
          return isSplashPath ? null : '/';
        }

        // Rule 2: User IS Authenticated (AuthAuthenticated)
        if (loggedIn) {
          debugPrint('Status: User authenticated.');
          // If on a public path (splash, login, forgot password), redirect to home (default app start).
          if (isCurrentPathPublic) {
            debugPrint(
                'Result: Logged in, on public path. Redirecting to /home.');
            return '/home';
          }
          // Otherwise, allow to proceed to the current requested (protected) path.
          debugPrint('Result: Logged in, on protected path. Allow access.');
          return null;
        }

        // Rule 3: User is NOT Authenticated (AuthUnauthenticated or AuthError, and check is complete)
        debugPrint('Status: User NOT authenticated (check complete).');
        // If on a login or forgot password page, allow.
        if (isLoginPagePath || isForgotPasswordPath) {
          debugPrint('Result: Not logged in, on auth path. Allow access.');
          return null;
        }
        // If on splash screen or any protected route, redirect to login.
        debugPrint(
            'Result: Not logged in, on splash or protected path. Redirecting to /login.');
        return '/login';
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