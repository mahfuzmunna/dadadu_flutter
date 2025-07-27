// lib/core/routes/app_router.dart

import 'dart:async'; // For StreamSubscription

// import 'package:dadadu_app/core/common/widgets/scaffold_with_nav_bar.dart'; // Ensure this path is correct
import 'package:dadadu_app/core/common/widgets/scaffold_with_navbar.dart'; // Ensure this path is correct
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
import 'package:dadadu_app/features/now/presentation/pages/now_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/user_video_page.dart';
import 'package:dadadu_app/features/settings/presentation/pages/settings_page.dart';
// import 'package:dadadu_app/features/upload/presentation/pages/upload_page_s.dart'; // If you're using this
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/discover/presentation/pages/vibe_users_page.dart';
import '../../features/now/now_injection.dart' as di;
import '../../features/posts/presentation/pages/upload_page.dart';
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
          path: '/discover/users', // The path for the new page
          builder: (context, state) {
            // We pass the vibe and position as a map in the 'extra' parameter
            final args = state.extra as Map<String, dynamic>;
            final vibe = args['vibe'] as String;
            final position = args['position'] as Position;

            return VibeUsersPage(vibe: vibe, currentPosition: position);
          },
        ),
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
            return const UploadPage(); // Or UploadPage, depending on your flow
            // return UploadPage(videoPath: videoPath); // Or UploadPage, depending on your flow
          },
        ),
        GoRoute(
          path: '/editProfile',
          builder: (BuildContext context, GoRouterState state) =>
              const EditProfilePage(),
        ),
        GoRoute(
          path: '/users-video',
          builder: (BuildContext context, GoRouterState state) =>
              const UsersVideoPage(),
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
                  builder: (context, state) => const NowPage(),
                ),
              ],
            ),
            // Discover
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/discover',
                  builder: (context, state) => DiscoverPage(),
                ),
              ],
            ),
            // Upload (Redirects to Camera)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/upload',
                    builder: (context, state) => const UploadPage()
                    // redirect: (context, state) => '/camera',
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
                      return ProfilePage(userId: authState.user.id);
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
                        // return BlocProvider<ProfileBloc>(
                        //   create: (context) => di.sl<ProfileBloc>()
                        //     ..add(LoadUserProfile(userId: userId)),

                        return BlocProvider<ProfileBloc>(
                          create: (context) => di.sl<ProfileBloc>()
                            ..add(SubscribeToUserProfile(userId)),
                          // The ProfilePage now takes NO arguments for this route.
                          // It will get all its data from the ProfileBloc.
                          child: ProfilePage(userId: userId),
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

        // 1. Define public and onboarding routes
        const publicRoutes = ['/login', '/signUp', '/forgot-password'];
        const onboardingRoute = '/upload-profile-photo';

        final isOnPublicRoute = publicRoutes.contains(currentLocation);
        final isOnOnboardingRoute = currentLocation == onboardingRoute;
        final isOnSplash = currentLocation == '/';

        // 2. Handle INITIALIZING state
        if (authState is AuthInitial || authState is AuthLoading) {
          // While initializing, only allow the splash screen
          return isOnSplash ? null : '/';
        }

        // 3. Handle SIGN UP SUCCESS (Onboarding) state
        if (authState is AuthSignUpSuccess) {
          // If user is in onboarding, they can ONLY be on the onboarding route
          return isOnOnboardingRoute ? null : onboardingRoute;
        }

        // 4. Handle AUTHENTICATED state
        if (authState is AuthAuthenticated) {
          // If logged in, they should NOT be on public auth routes, onboarding, or splash
          if (isOnPublicRoute || isOnOnboardingRoute || isOnSplash) {
            return '/home';
          }
        }

        // 5. Handle UNAUTHENTICATED state
        else {
          // If logged out, they can ONLY be on public routes
          if (!isOnPublicRoute) {
            return '/login';
          }
        }

        // 6. No redirection needed
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