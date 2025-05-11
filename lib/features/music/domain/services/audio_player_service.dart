import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as dev;

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<double>? _bufferingProgressSubscription;

  AudioPlayerService() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Configure the audio session for playback
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Listen to player state changes
      _playerStateSubscription = _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      });

      // Set up error handling
      _player.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          dev.log('A stream error occurred: $e');
        },
      );
    } catch (e) {
      dev.log('Error initializing audio player: $e');
    }
  }

  // Play a track from URL with improved buffering
  Future<Duration?> playTrackWithBuffering(String url) async {
    try {
      dev.log('Loading track from URL: $url');
      await _player.stop();

      // Configure player to start as soon as sufficient data is buffered
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        initialPosition: Duration.zero,
        // Start playback immediately when enough is buffered
        preload: true,
      );

      // Start playback as soon as buffering begins
      _player.setAutomaticallyWaitsToMinimizeStalling(false);

      // Start playback
      await _player.play();

      return _player.duration;
    } catch (e) {
      dev.log('Error playing track with buffering: $e');
      return null;
    }
  }

  // Original play track method
  Future<Duration?> playTrack(String url) async {
    try {
      dev.log('Loading track from URL: $url');
      await _player.stop();

      // Set the audio source
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));

      // Get the duration
      final duration = _player.duration;

      // Start playback
      await _player.play();

      return duration;
    } catch (e) {
      dev.log('Error playing track: $e');
      return null;
    }
  }

  // Basic player controls
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      dev.log('Error playing: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      dev.log('Error pausing: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      dev.log('Error stopping: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      dev.log('Error seeking: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume);
    } catch (e) {
      dev.log('Error setting volume: $e');
    }
  }

  // Streams for player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get bufferingProgressStream =>
      _player.bufferedPositionStream.map((bufferedPosition) {
        final duration = _player.duration;
        if (duration == null || duration.inMilliseconds == 0) {
          return 0.0;
        }
        return bufferedPosition.inMilliseconds / duration.inMilliseconds;
      });

  // Get current values
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  double get bufferingProgress {
    final duration = _player.duration;
    final bufferedPosition = _player.bufferedPosition;

    if (duration == null || duration.inMilliseconds == 0) {
      return 0.0;
    }
    return bufferedPosition.inMilliseconds / duration.inMilliseconds;
  }

  // Listen to position changes
  void listenToPosition(Function(Duration) onPositionChanged) {
    _positionSubscription?.cancel();
    _positionSubscription = _player.positionStream.listen(onPositionChanged);
  }

  // Listen to duration changes
  void listenToDuration(Function(Duration?) onDurationChanged) {
    _durationSubscription?.cancel();
    _durationSubscription = _player.durationStream.listen(onDurationChanged);
  }

  // Listen to buffering progress
  void listenToBufferingProgress(Function(double) onBufferingProgressChanged) {
    _bufferingProgressSubscription?.cancel();
    _bufferingProgressSubscription =
        bufferingProgressStream.listen(onBufferingProgressChanged);
  }

  // Clean up
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingProgressSubscription?.cancel();
    _player.dispose();
  }
}
