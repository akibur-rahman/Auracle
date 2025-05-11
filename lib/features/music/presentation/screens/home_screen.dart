import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../application/home_provider.dart';
import '../../application/player_provider.dart';
import '../../application/tracks_provider.dart';
import '../../domain/models/album.dart';
import '../../domain/models/playlist.dart';
import '../../domain/models/song.dart';
import '../widgets/album_card.dart';
import '../widgets/playlist_card.dart';
import '../widgets/section_header.dart';
import '../widgets/mini_player.dart';
import '../widgets/track_list.dart';
import '../../../../features/auth/domain/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  final bool showMiniPlayer;

  const HomeScreen({super.key, this.showMiniPlayer = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final tracksAsync = ref.watch(tracksProvider);
    final user = ref.watch(authServiceProvider).valueOrNull;
    final initialSongAsync = ref.watch(initialSongProvider);

    // Initialize the current song when the home screen is loaded
    ref.listen<AsyncValue<HomeViewModel>>(homeDataProvider, (_, state) {
      if (state.hasValue && ref.read(currentSongProvider) == null) {
        // Set initial song from Firebase
        initialSongAsync.whenData((song) {
          if (song != null && ref.read(currentSongProvider) == null) {
            ref.read(currentSongProvider.notifier).state = song;
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: homeDataAsync.when(
                data: (homeData) =>
                    _buildContent(context, homeData, ref, user, tracksAsync),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildError(context, error),
              ),
            ),
            // Mini Player
            if (showMiniPlayer) const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    HomeViewModel homeData,
    WidgetRef ref,
    User? user,
    AsyncValue<List<Song>> tracksAsync,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildGreeting(context, user)),
        if (homeData.recentlyPlayed.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Recently Played', onSeeAllTap: () {}),
          ),
          SliverToBoxAdapter(
            child: _buildRecentlyPlayed(context, homeData.recentlyPlayed, ref),
          ),
        ],
        if (homeData.YourPlaylist.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Your Playlists', onSeeAllTap: () {}),
          ),
          SliverToBoxAdapter(
            child: _buildYourPlaylists(context, homeData.YourPlaylist, ref),
          ),
        ],
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'All Tracks',
            onSeeAllTap: () => context.push('/all-tracks'),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildTracks(context, tracksAsync, ref),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context, User? user) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    // Get the first name from display name or use a default
    final displayName = user?.displayName ?? 'User';
    final firstName = displayName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            firstName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayed(
    BuildContext context,
    List<Album> albums,
    WidgetRef ref,
  ) {
    final controls = ref.watch(playerControlsProvider);
    final tracksAsync = ref.watch(tracksProvider.future);
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);

    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AlbumCard(
              album: album,
              onTap: () async {
                final tracks = await tracksAsync;

                // Try to find the matching song from recentlyPlayed
                Song? songToPlay;

                // First check if we have it in recently played
                for (final song in recentlyPlayed) {
                  if (song.id == album.id) {
                    songToPlay = song;
                    break;
                  }
                }

                // If not found in recently played, search in all tracks
                if (songToPlay == null) {
                  for (final song in tracks) {
                    if (song.id == album.id) {
                      songToPlay = song;
                      break;
                    }
                  }
                }

                // If still not found, use first track as fallback
                if (songToPlay == null && tracks.isNotEmpty) {
                  songToPlay = tracks.first;
                }

                if (songToPlay != null) {
                  // Add all tracks to queue starting with the selected track
                  final queue = [...tracks];
                  final selectedIndex =
                      queue.indexWhere((s) => s.id == songToPlay!.id);
                  final index = selectedIndex >= 0 ? selectedIndex : 0;

                  // Play with queue so skip next/prev will work
                  await controls.playWithQueue(songToPlay, queue, index);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildYourPlaylists(
    BuildContext context,
    List<Playlist> playlists,
    WidgetRef ref,
  ) {
    final controls = ref.watch(playerControlsProvider);

    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PlaylistCard(
              playlist: playlists[index],
              onTap: () async {
                // Find first available song
                final tracks = await ref.read(tracksProvider.future);
                if (tracks.isNotEmpty) {
                  // Play all tracks in the playlist with queue setup
                  await controls.playWithQueue(tracks.first, tracks, 0);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTracks(
    BuildContext context,
    AsyncValue<List<Song>> tracksAsync,
    WidgetRef ref,
  ) {
    return tracksAsync.when(
      data: (tracks) => tracks.isEmpty
          ? _buildEmptyTracks(context)
          : SizedBox(
              height: 300,
              child: TrackList(
                songs: tracks,
                scrollable: false,
              ),
            ),
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildEmptyTracks(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tracks available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final errorMessage = error.toString();
    final isIndexError = errorMessage.contains('index');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Error loading content\n',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red,
                    ),
              ),
              if (isIndexError) ...[
                TextSpan(
                  text: 'Firebase index is missing.\n\n',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextSpan(
                  text:
                      'Please click the link in the error message below to create the required index in Firebase:\n\n',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              TextSpan(
                text: errorMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
