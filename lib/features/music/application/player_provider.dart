import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as dev;
import '../domain/models/song.dart';
import '../domain/services/audio_player_service.dart';
import 'tracks_provider.dart';

// Providers for player state
final currentSongProvider = StateProvider<Song?>((ref) => null);
final isPlayingProvider = StateProvider<bool>((ref) => false);
final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final totalDurationProvider = StateProvider<Duration>((ref) => Duration.zero);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final playbackErrorProvider = StateProvider<String?>((ref) => null);
final bufferingProgressProvider = StateProvider<double>((ref) => 0.0);

// Queue management providers
final playQueueProvider = StateProvider<List<Song>>((ref) => []);
final currentQueueIndexProvider = StateProvider<int>((ref) => 0);

// Recently played tracks (keep only the last 5)
final recentlyPlayedProvider = StateProvider<List<Song>>((ref) => []);

// Track playback URI provider (encapsulates Firebase storage URL)
final trackPlaybackUriProvider =
    Provider.family<String, String>((ref, storageUrl) {
  // Return the storage URL directly - we'll use it to play from Firebase Storage
  return storageUrl;
});

// Initial song provider
final initialSongProvider = FutureProvider<Song?>((ref) async {
  try {
    // Watch the stream instead of the future
    final tracks = await ref.watch(tracksStreamProvider.future);
    return tracks.isNotEmpty ? tracks.first : null;
  } catch (e) {
    dev.log('Error getting initial song: $e');
    return null;
  }
});

// Player controls provider that uses AudioPlayerService
final playerControlsProvider = Provider<PlayerControls>((ref) {
  return PlayerControls(ref);
});

class PlayerControls {
  final Ref _ref;
  String? _lastPlayedUrl;

  PlayerControls(this._ref) {
    _initializeAudioPlayerListeners();
  }

  void _initializeAudioPlayerListeners() {
    final audioPlayerService = _ref.read(audioPlayerServiceProvider);

    // Listen to position changes
    audioPlayerService.listenToPosition((position) {
      _ref.read(currentPositionProvider.notifier).state = position;
    });

    // Listen to duration changes
    audioPlayerService.listenToDuration((duration) {
      if (duration != null) {
        _ref.read(totalDurationProvider.notifier).state = duration;
      }
    });

    // Listen to buffering progress
    audioPlayerService.listenToBufferingProgress((progress) {
      _ref.read(bufferingProgressProvider.notifier).state = progress;
    });

    // Listen to player state changes
    audioPlayerService.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      _ref.read(isPlayingProvider.notifier).state = isPlaying;

      // Update loading state based on processing state
      _ref.read(isLoadingProvider.notifier).state =
          state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;

      // Handle errors
      if (state.processingState == ProcessingState.completed) {
        // Reset position when completed
        _ref.read(currentPositionProvider.notifier).state = Duration.zero;
      }
    });
  }

  // Add to recently played list
  void _addToRecentlyPlayed(Song song) {
    final recentlyPlayed = List<Song>.from(_ref.read(recentlyPlayedProvider));

    // Remove the song if it already exists in the list
    recentlyPlayed.removeWhere((s) => s.id == song.id);

    // Add the song to the front of the list
    recentlyPlayed.insert(0, song);

    // Limit to 5 recently played songs
    if (recentlyPlayed.length > 5) {
      recentlyPlayed.removeLast();
    }

    // Update the provider
    _ref.read(recentlyPlayedProvider.notifier).state = recentlyPlayed;
  }

  // Add song to queue and play it
  Future<void> playWithQueue(Song song, List<Song> queue,
      [int index = 0]) async {
    // Update the queue
    _ref.read(playQueueProvider.notifier).state = queue;
    _ref.read(currentQueueIndexProvider.notifier).state = index;

    // Update current song and play it
    _ref.read(currentSongProvider.notifier).state = song;
    await play();
  }

  Future<void> play() async {
    final audioPlayerService = _ref.read(audioPlayerServiceProvider);
    final currentSong = _ref.read(currentSongProvider);
    final isPlaying = _ref.read(isPlayingProvider);

    // Clear any previous errors
    _ref.read(playbackErrorProvider.notifier).state = null;

    if (currentSong != null) {
      try {
        // Get the Firebase storage URL
        final storageUrl = currentSong.storageUrl;
        if (storageUrl == null || storageUrl.isEmpty) {
          _ref.read(playbackErrorProvider.notifier).state =
              'No audio URL available for this track';
          return;
        }

        final playbackUrl = _ref.read(trackPlaybackUriProvider(storageUrl));

        // If the same song is already playing, just toggle play/pause
        if (isPlaying) {
          await pause();
          return;
        }

        // If we're resuming the same song, just play from current position
        if (_lastPlayedUrl == playbackUrl) {
          _ref.read(isLoadingProvider.notifier).state = true;
          await audioPlayerService.play();
          _ref.read(isLoadingProvider.notifier).state = false;
          return;
        }

        // New song or first play
        _ref.read(isLoadingProvider.notifier).state = true;
        dev.log('Playing track from URL: $playbackUrl');

        // Load and play the track with auto-buffering enabled
        final duration =
            await audioPlayerService.playTrackWithBuffering(playbackUrl);

        if (duration != null) {
          _ref.read(totalDurationProvider.notifier).state = duration;
          _lastPlayedUrl = playbackUrl;

          // Add to recently played
          _addToRecentlyPlayed(currentSong);
        }
      } catch (e) {
        dev.log('Error playing track: $e');
        _ref.read(playbackErrorProvider.notifier).state =
            'Failed to play track: $e';
      } finally {
        _ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> pause() async {
    final audioPlayerService = _ref.read(audioPlayerServiceProvider);
    await audioPlayerService.pause();
  }

  Future<void> togglePlayPause() async {
    final isPlaying = _ref.read(isPlayingProvider);
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> skipToNext() async {
    final queue = _ref.read(playQueueProvider);
    final currentIndex = _ref.read(currentQueueIndexProvider);

    // If queue is empty or only has one song, just restart current song
    if (queue.isEmpty || queue.length <= 1) {
      await seekTo(Duration.zero);
      await play();
      return;
    }

    // Calculate next index, wrapping around if needed
    final nextIndex = (currentIndex + 1) % queue.length;

    // Update index and current song
    _ref.read(currentQueueIndexProvider.notifier).state = nextIndex;
    _ref.read(currentSongProvider.notifier).state = queue[nextIndex];

    // Play the new song
    await play();
  }

  Future<void> skipToPrevious() async {
    final queue = _ref.read(playQueueProvider);
    final currentIndex = _ref.read(currentQueueIndexProvider);

    // If queue is empty or only has one song, just restart current song
    if (queue.isEmpty || queue.length <= 1) {
      await seekTo(Duration.zero);
      await play();
      return;
    }

    // Calculate previous index, wrapping around if needed
    final prevIndex = (currentIndex - 1 + queue.length) % queue.length;

    // Update index and current song
    _ref.read(currentQueueIndexProvider.notifier).state = prevIndex;
    _ref.read(currentSongProvider.notifier).state = queue[prevIndex];

    // Play the new song
    await play();
  }

  Future<void> seekTo(Duration position) async {
    final audioPlayerService = _ref.read(audioPlayerServiceProvider);
    await audioPlayerService.seekTo(position);
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
        storageUrl: currentSong.storageUrl,
        isFavorite: !currentSong.isFavorite,
      );
      _ref.read(currentSongProvider.notifier).state = updatedSong;
    }
  }

  Future<void> stop() async {
    final audioPlayerService = _ref.read(audioPlayerServiceProvider);
    await audioPlayerService.stop();
    _lastPlayedUrl = null;
  }
}
