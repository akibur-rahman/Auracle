import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/player_screen.dart';
import '../../application/player_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialSongAsync = ref.watch(initialSongProvider);
    final currentSongValue = ref.watch(currentSongProvider);
    final currentSong = currentSongValue ?? initialSongAsync.valueOrNull;

    // Don't show mini player if there's no song or if it's still loading
    if (currentSong == null || initialSongAsync.isLoading) {
      return const SizedBox.shrink();
    }

    final isPlaying = ref.watch(isPlayingProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final controls = ref.watch(playerControlsProvider);
    final bufferingProgress = ref.watch(bufferingProgressProvider);

    return GestureDetector(
      onTap: () => PlayerScreen.navigateToPlayer(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: currentSong.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, size: 24),
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentSong.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.artist,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[400]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (bufferingProgress > 0 && bufferingProgress < 1.0)
                      LinearProgressIndicator(
                        value: bufferingProgress,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 2,
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: controls.skipToPrevious,
              color: Colors.white,
              iconSize: 24,
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: isLoading ? null : controls.togglePlayPause,
              color: Colors.white,
              iconSize: 32,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: controls.skipToNext,
              color: Colors.white,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}
