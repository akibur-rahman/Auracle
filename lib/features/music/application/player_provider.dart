import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/song.dart';

final currentSongProvider = StateProvider<Song?>((ref) => null);

final isPlayingProvider = StateProvider<bool>((ref) => false);

final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);

final totalDurationProvider = StateProvider<Duration>(
  (ref) => const Duration(minutes: 4, seconds: 15),
);

final mockSongProvider = Provider<Song>((ref) {
  return Song(
    id: '1',
    title: 'Midnight Memories',
    artist: 'Taylor Swift',
    albumName: 'Midnights',
    imageUrl:
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400',
    duration: '4:15',
  );
});

final playerControlsProvider = Provider<PlayerControls>((ref) {
  return PlayerControls(ref);
});

class PlayerControls {
  final Ref _ref;

  PlayerControls(this._ref);

  void play() {
    _ref.read(isPlayingProvider.notifier).state = true;
  }

  void pause() {
    _ref.read(isPlayingProvider.notifier).state = false;
  }

  void togglePlayPause() {
    final isPlaying = _ref.read(isPlayingProvider);
    _ref.read(isPlayingProvider.notifier).state = !isPlaying;
  }

  void skipToNext() {
    // In a real app, this would handle moving to the next song
    pause();
    _ref.read(currentPositionProvider.notifier).state = Duration.zero;
    play();
  }

  void skipToPrevious() {
    // In a real app, this would handle moving to the previous song
    pause();
    _ref.read(currentPositionProvider.notifier).state = Duration.zero;
    play();
  }

  void seekTo(Duration position) {
    _ref.read(currentPositionProvider.notifier).state = position;
  }

  void toggleFavorite() {
    final currentSong = _ref.read(currentSongProvider);
    if (currentSong != null) {
      final updatedSong = Song(
        id: currentSong.id,
        title: currentSong.title,
        artist: currentSong.artist,
        albumName: currentSong.albumName,
        imageUrl: currentSong.imageUrl,
        duration: currentSong.duration,
        isPlaying: currentSong.isPlaying,
        isFavorite: !currentSong.isFavorite,
      );
      _ref.read(currentSongProvider.notifier).state = updatedSong;
    }
  }
}
