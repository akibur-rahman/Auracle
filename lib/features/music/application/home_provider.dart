import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/album.dart';
import '../domain/models/playlist.dart';
import '../domain/models/song.dart';
import 'tracks_provider.dart';
import 'player_provider.dart';

// Convert to StreamProvider for real-time updates
final homeDataProvider = StreamProvider<HomeViewModel>((ref) async* {
  // Get the recently played tracks from the provider
  final recentlyPlayed = ref.watch(recentlyPlayedProvider);

  // Initial state with recently played (if available)
  yield HomeViewModel(
    recentlyPlayed: recentlyPlayed.isNotEmpty
        ? _createAlbumsFromTracks(recentlyPlayed)
        : [],
    YourPlaylist: [],
    LocalMusic: [],
  );

  // Stream of tracks to get real-time updates
  await for (final trackSnapshot in ref.watch(tracksStreamProvider.stream)) {
    final recentAlbums = recentlyPlayed.isNotEmpty
        ? _createAlbumsFromTracks(recentlyPlayed)
        : _createAlbumsFromTracks(trackSnapshot);

    // Get playlists (empty list for now)
    final playlists = <Playlist>[];

    // Yield updated data
    yield HomeViewModel(
      recentlyPlayed: recentAlbums,
      YourPlaylist: playlists,
      LocalMusic: [], // No local music for now
    );
  }
});

// Helper to create album objects from tracks
List<Album> _createAlbumsFromTracks(List<Song> tracks) {
  // Convert tracks to albums
  return tracks
      .map((song) => Album(
            id: song.id,
            title: song.title,
            artist: song.artist,
            imageUrl: song.imageUrl,
          ))
      .toList();
}

class HomeViewModel {
  final List<Album> recentlyPlayed;
  final List<Playlist> YourPlaylist;
  final List<Song> LocalMusic;

  HomeViewModel({
    required this.recentlyPlayed,
    required this.YourPlaylist,
    required this.LocalMusic,
  });
}
