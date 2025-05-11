import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../application/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  static void navigateToPlayer(BuildContext context) {
    context.push('/player');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialSongAsync = ref.watch(initialSongProvider);
    final currentSongValue = ref.watch(currentSongProvider);
    final currentSong = currentSongValue ?? initialSongAsync.valueOrNull;

    final isPlaying = ref.watch(isPlayingProvider);
    final currentPosition = ref.watch(currentPositionProvider);
    final totalDuration = ref.watch(totalDurationProvider);
    final controls = ref.watch(playerControlsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final playbackError = ref.watch(playbackErrorProvider);
    final bufferingProgress = ref.watch(bufferingProgressProvider);

    // If no song is available, show loading or empty state
    if (currentSong == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Now Playing'),
          centerTitle: true,
        ),
        body: initialSongAsync.when(
          data: (_) => const Center(
            child: Text('No songs available',
                style: TextStyle(color: Colors.white)),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Error loading music: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.queue_music), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Album Art
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: currentSong.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.music_note, size: 80),
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                          if (bufferingProgress > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Buffering ${(bufferingProgress * 100).toInt()}%',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Song Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.title,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentSong.artist,
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        currentSong.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: currentSong.isFavorite
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        size: 28,
                      ),
                      onPressed: controls.toggleFavorite,
                    ),
                  ],
                ),
                if (playbackError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      playbackError,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Theme.of(context).colorScheme.primary,
                    overlayColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: currentPosition.inSeconds.toDouble(),
                    min: 0,
                    max: totalDuration.inSeconds.toDouble() > 0
                        ? totalDuration.inSeconds.toDouble()
                        : 1.0,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            controls.seekTo(Duration(seconds: value.toInt()));
                          },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(currentPosition),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (bufferingProgress > 0 &&
                    bufferingProgress < 1.0 &&
                    !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buffering ${(bufferingProgress * 100).toInt()}%',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.only(
              bottom: 48.0,
              left: 24.0,
              right: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: () {},
                  iconSize: 26,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: isLoading ? null : controls.skipToPrevious,
                  iconSize: 40,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ))
                        : Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                          ),
                    onPressed: isLoading ? null : controls.togglePlayPause,
                    iconSize: 40,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: isLoading ? null : controls.skipToNext,
                  iconSize: 40,
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: () {},
                  iconSize: 26,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
