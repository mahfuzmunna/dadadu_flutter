// lib/core/routes/app_router.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../core/common/widgets/scaffold_with_navbar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router({required AuthBloc authBloc}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final bool isAuthenticated = authState is Authenticated;
        final bool isUnauthenticated = authState is Unauthenticated;
        final bool isSignInPage = state.matchedLocation == '/signIn';
        final bool isSignUpPage = state.matchedLocation == '/signUp';
        final bool isSplashPage = state.matchedLocation == '/splash';

        if (isUnauthenticated && !isSignInPage && !isSignUpPage && !isSplashPage) {
          return '/signIn';
        }
        if (isAuthenticated && (isSignInPage || isSignUpPage || isSplashPage)) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(
          path: '/signIn',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/signUp',
          builder: (context, state) => const SignUpPage(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            // Pass the current path from GoRouterState to ScaffoldWithNavBar
            return ScaffoldWithNavBar(
              currentLocation: state.matchedLocation, // <--- Pass this
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverPage(),
            ),
            GoRoute(
              path: '/upload',
              builder: (context, state) => const UploadPage(),
            ),
            GoRoute(
              path: '/friends',
              builder: (context, state) => const FriendsPage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}