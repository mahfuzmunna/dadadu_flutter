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
import 'package:dadadu_app/features/chat/presentation/pages/chats_page.dart';
// import 'package:dadadu_app/features/auth/presentation/pages/sign_up_page_t.dart'; // No longer explicitly needed if LoginPage handles signup
import 'package:dadadu_app/features/discover/presentation/pages/discover_page.dart';
import 'package:dadadu_app/features/now/presentation/pages/now_page.dart';
import 'package:dadadu_app/features/posts/domain/entities/post_draft.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/posts/presentation/pages/video_editor_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/profile_page.dart';
import 'package:dadadu_app/features/profile/presentation/pages/user_video_page_s.dart';
import 'package:dadadu_app/features/settings/presentation/pages/settings_page.dart';
// import 'package:dadadu_app/features/upload/presentation/pages/create_post_camera_page.dart'; // If you're using this
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/chat/presentation/pages/chat_page_s.dart';
import '../../features/now/now_injection.dart' as di;
import '../../features/posts/presentation/pages/create_post_camera_page.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
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
        // GoRoute(
        //   path: '/discover/users', // The path for the new page
        //   builder: (context, state) {
        //     // We pass the vibe and position as a map in the 'extra' parameter
        //     final args = state.extra as Map<String, dynamic>;
        //     final vibe = args['vibe'] as String;
        //     final position = args['position'] as Position;
        //     final distance = args['distance'] as double;
        //
        //     return VibeUsersPage(
        //         vibe: vibe, currentPosition: position, maxDistance: distance);
        //   },
        //   routes: [
        //     GoRoute(
        //       path: ':userId',
        //       builder: (BuildContext context, GoRouterState state) {
        //         final String postId = state.pathParameters['userId']!;
        //         return UsersVideoPage(postId: postId);
        //       },
        //     ),
        //   ]
        // ),
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
            final args = state.extra as Map<String, dynamic>;
            final videoPath = args['videoPath'] as String;
            final draft = args['draft'] as PostDraft;
            return BlocProvider<PostBloc>(
              create: (context) => di.sl<PostBloc>(),
              child: CreatePostPage(
                videoPath: videoPath,
                initialDraft: draft,
              ),
            );
          },
        ),
        GoRoute(
          path: '/videoEditor',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final videoPath = args['videoPath'] as String;
            final draft = args['draft'] as PostDraft;

            return VideoEditorPage(videoFilePath: videoPath, draft: draft);
          },
        ),

        GoRoute(
          path: '/chat/:roomId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            // Extract the roomId from the path parameters
            final String roomId = state.pathParameters['roomId']!;
            return ChatPage(roomId: roomId);
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
                  builder: (context, state) => const NowPage(),
                  routes: [
                    GoRoute(
                      path: ':postId',
                      builder: (BuildContext context, GoRouterState state) {
                        final String postId = state.pathParameters['postId']!;
                        return BlocProvider<ProfileBloc>(
                          create: (context) => di.sl<ProfileBloc>()
                            ..add(SubscribeToUserProfile(postId)),
                          child: UsersVideoPage(postId: postId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Discover
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/discover',
                  // builder: (context, state) => DiscoverPage(),
                  builder: (BuildContext context, GoRouterState state) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      // Pass the currently logged-in user to the ProfilePage
                      return DiscoverPage(userId: authState.user.id);
                    }
                    // Fallback or loading state if needed
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
            // Upload (Redirects to Camera)
            StatefulShellBranch(
              routes: [
                GoRoute(
                    path: '/createPostCamera',
                    builder: (context, state) => const CreatePostCameraPage()
                    // redirect: (context, state) => '/createPostCamera',
                    ),
              ],
            ),
            // Friends
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/chats',
                  builder: (context, state) => const ChatsPage(),
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
                          child: ProfilePage(
                              key: ValueKey(userId), userId: userId),
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
        final location = state.uri.toString();

        // Define route locations and public paths
        const splashLocation = '/';
        const loginLocation = '/login';
        const homeLocation = '/home';
        const onboardingLocation = '/upload-profile-photo';
        const authRoutes = ['/login', '/signUp', '/forgot-password'];

        final isAtAuthRoute = authRoutes.contains(location);
        final isAtOnboarding = location == onboardingLocation;

        // 1. While the app is initializing, stay on the splash screen.
        // This prevents redirects before the auth state is resolved.
        if (authState is AuthInitial || authState is AuthLoading) {
          return location == splashLocation ? null : splashLocation;
        }

        // 2. If the user just signed up, they MUST go to onboarding.
        if (authState is AuthSignUpSuccess) {
          return location == onboardingLocation ? null : onboardingLocation;
        }

        // 3. If the user is authenticated:
        if (authState is AuthAuthenticated) {
          // If they are on a public page (auth, onboarding) or the splash screen, send them home.
          if (isAtAuthRoute || isAtOnboarding || location == splashLocation) {
            return homeLocation;
          }
          // Otherwise, they are on a protected page and can stay.
          return null;
        }

        // 4. If the user is NOT authenticated (or in an error state):
        // They should only be on the auth routes. If they are anywhere else, redirect them to login.
        // The splash screen is not a valid destination after loading is complete for an unauthenticated user.
        if (!isAtAuthRoute) {
          return loginLocation;
        }

        // 5. If unauthenticated and on an auth route, no redirect is needed.
        return null;
      },

      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(child: Text('Error: No route found for ${state.uri}')),
      ),

      // Listens to AuthBloc's stream to trigger redirects whenever auth state changes.
      refreshListenable: GoRouterRefreshStream(authBloc.status),
    );
  }
}

/// A `Listenable` that notifies `GoRouter` when a `Stream` emits a new value.
/// Used to trigger re-evaluation of the router's `redirect` logic.
// class GoRouterRefreshStream extends ChangeNotifier {
//   late final StreamSubscription<dynamic> _subscription;
//
//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners(); // Notify listeners immediately on creation
//     _subscription = stream.asBroadcastStream().listen(
//           (dynamic _) =>
//               notifyListeners(), // Notify listeners whenever the stream emits
//         );
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel(); // Cancel the subscription to prevent memory leaks
//     super.dispose();
//   }
// }

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthenticationStatus> _subscription;

  GoRouterRefreshStream(Stream<AuthenticationStatus> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
