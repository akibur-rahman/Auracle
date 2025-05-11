import 'package:auracle/features/music/presentation/screens/search_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/music/presentation/screens/home_screen.dart';
import '../../features/music/presentation/screens/library_screen.dart';
import '../../features/music/presentation/screens/player_screen.dart';
import '../../features/music/presentation/screens/all_tracks_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/creator/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/domain/auth_service.dart';
import 'app_navigation.dart';

const _publicPaths = ['/login', '/signup'];

final routerProvider = Provider<GoRouter>((ref) {
  // Watch user authentication state
  final userAuthState = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true, // Enable router logging for debugging
    redirect: (context, state) async {
      final isUserLoggedIn = userAuthState.valueOrNull != null;

      // Fix: Use location instead of fullPath which might be null
      final currentPath = state.matchedLocation;

      final isGoingToPublicPage = _publicPaths.contains(currentPath);

      // REGULAR USER AUTHENTICATION LOGIC
      // If not logged in and trying to access protected route, redirect to login
      if (!isUserLoggedIn && !isGoingToPublicPage) {
        return '/login';
      }

      // If logged in and trying to access login/signup page, redirect to home
      if (isUserLoggedIn &&
          (currentPath == '/login' || currentPath == '/signup')) {
        return '/';
      }

      // No redirection needed
      return null;
    },
    refreshListenable: GoRouterRefreshNotifier(ref),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppNavigation(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const SearchScreen()),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const LibraryScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: '/all-tracks',
        builder: (context, state) => const AllTracksScreen(),
      ),
      GoRoute(
        path: '/creator-dashboard',
        builder: (context, state) => const CreatorDashboardScreen(),
      ),
    ],
  );
});

// Helper class to use Riverpod ProviderContainer as a refresh notifier for GoRouter
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    // Listen to user authentication state changes
    _userAuthSubscription = _ref.listen(authServiceProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription _userAuthSubscription;

  @override
  void dispose() {
    _userAuthSubscription.close();
    super.dispose();
  }
}
