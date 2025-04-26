import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../application/player_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong =
        (ref.watch(currentSongProvider) ?? ref.watch(mockSongProvider))!;
    final isPlaying = ref.watch(isPlayingProvider);
    final controls = ref.watch(playerControlsProvider);

    return GestureDetector(
      onTap: () => PlayerScreen.navigateToPlayer(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Album Art
            SizedBox(
              height: 60,
              width: 60,
              child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: currentSong.imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.music_note),
                      ),
                ),
              ),
            ),

            // Song Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.artist,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Controls
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: controls.togglePlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: controls.skipToNext,
            ),
          ],
        ),
      ),
    );
  }
}
