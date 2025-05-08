import 'package:auracle/features/music/presentation/screens/search_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/music/presentation/screens/home_screen.dart';
import '../../features/music/presentation/screens/library_screen.dart';
import '../../features/music/presentation/screens/player_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'app_navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppNavigation(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder:
                (context, state) => NoTransitionPage(child: const HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const SearchScreen()),
          ),
          GoRoute(
            path: '/library',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const LibraryScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const PlayerScreen(),
      ),
    ],
  );
});
