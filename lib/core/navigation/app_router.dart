import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/music/presentation/screens/home_screen.dart';
import '../../features/music/presentation/screens/library_screen.dart';
import '../../features/music/presentation/screens/player_screen.dart';
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
                (context, state) => NoTransitionPage(
                  child: Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
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
                (context, state) => NoTransitionPage(
                  child: Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
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
