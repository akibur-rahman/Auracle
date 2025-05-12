import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song.dart';
import '../../application/player_provider.dart';

class TrackList extends ConsumerWidget {
  final List<Song> songs;
  final bool scrollable;
  final bool showNumbers;

  const TrackList({
    super.key,
    required this.songs,
    this.scrollable = true,
    this.showNumbers = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final controls = ref.watch(playerControlsProvider);

    return ListView.builder(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isSelected = currentSong?.id == song.id;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showNumbers)
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, size: 24),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                if (isSelected && isPlaying)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 24,
                    onPressed: controls.pause,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    iconSize: 24,
                    onPressed: () {
                      controls.playWithQueue(song, songs, index);
                    },
                  ),
              ],
            ),
            onTap: () {
              controls.playWithQueue(song, songs, index);
            },
          ),
        );
      },
    );
  }
}
