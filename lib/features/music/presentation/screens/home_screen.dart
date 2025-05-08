import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/home_provider.dart';
import '../../application/player_provider.dart';
import '../../domain/models/album.dart';
import '../../domain/models/playlist.dart';
import '../../domain/models/song.dart';
import '../widgets/album_card.dart';
import '../widgets/playlist_card.dart';
import '../widgets/section_header.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends ConsumerWidget {
  final bool showMiniPlayer;

  const HomeScreen({super.key, this.showMiniPlayer = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    // Initialize the current song when the home screen is loaded
    ref.listen<AsyncValue<HomeViewModel>>(homeDataProvider, (_, state) {
      if (state.hasValue && ref.read(currentSongProvider) == null) {
        ref.read(currentSongProvider.notifier).state = ref.read(
          mockSongProvider,
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: homeDataAsync.when(
                data: (homeData) => _buildContent(context, homeData, ref),
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
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildGreeting(context)),
        SliverToBoxAdapter(
          child: SectionHeader(title: 'Recently Played', onSeeAllTap: () {}),
        ),
        SliverToBoxAdapter(
          child: _buildRecentlyPlayed(context, homeData.recentlyPlayed, ref),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(title: 'Your Playlists', onSeeAllTap: () {}),
        ),
        SliverToBoxAdapter(
          child: _buildYourPlaylists(context, homeData.YourPlaylist, ref),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(title: 'Local Music', onSeeAllTap: () {}),
        ),
        SliverToBoxAdapter(
          child: _buildLocalMusic(context, homeData.LocalMusic, ref),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

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
            'Akibur',
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

    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AlbumCard(
              album: albums[index],
              onTap: () {
                // Create a mock song from the album
                final song = ref.read(mockSongProvider);
                ref.read(currentSongProvider.notifier).state = song;
                controls.play();
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
              onTap: () {
                // Start playing a song from the playlist
                final song = ref.read(mockSongProvider);
                ref.read(currentSongProvider.notifier).state = song;
                controls.play();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocalMusic(
    BuildContext context,
    List<Song> songs,
    WidgetRef ref,
  ) {
    final controls = ref.watch(playerControlsProvider);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
              ),
            ),
            title: Text(
              song.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${song.artist} • ${song.albumName}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  song.duration,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    ref.read(currentSongProvider.notifier).state = song;
                    controls.play();
                  },
                ),
              ],
            ),
            onTap: () {
              ref.read(currentSongProvider.notifier).state = song;
              controls.play();
            },
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Error loading content\n',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.red),
              ),
              TextSpan(
                text: error.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
