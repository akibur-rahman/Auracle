import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/album.dart';
import '../domain/models/playlist.dart';
import '../domain/models/song.dart';
import 'tracks_provider.dart';
import 'player_provider.dart';
import 'dart:developer' as dev;

// Create a simple provider that combines data from multiple sources
final homeDataProvider = Provider<AsyncValue<HomeViewModel>>((ref) {
  // Watch recently played tracks
  final recentlyPlayed = ref.watch(recentlyPlayedProvider);

  // Watch track data - use future provider initially to get immediate data
  final tracksAsync = ref.watch(tracksStreamProvider);

  // Combine the data
  return tracksAsync.when(
    data: (tracks) {
      final recentAlbums = recentlyPlayed.isNotEmpty
          ? _createAlbumsFromTracks(recentlyPlayed)
          : _createAlbumsFromTracks(tracks);

      return AsyncData(HomeViewModel(
        recentlyPlayed: recentAlbums,
        YourPlaylist: [], // Empty for now
        LocalMusic: [],
      ));
    },
    loading: () {
      // If we're still loading tracks but have recently played items,
      // show a partial view with just the recently played
      if (recentlyPlayed.isNotEmpty) {
        return AsyncData(HomeViewModel(
          recentlyPlayed: _createAlbumsFromTracks(recentlyPlayed),
          YourPlaylist: [],
          LocalMusic: [],
        ));
      }
      return const AsyncLoading();
    },
    error: (error, stack) {
      dev.log('Error in homeDataProvider: $error');
      // If we have recently played, still show those even on error
      if (recentlyPlayed.isNotEmpty) {
        return AsyncData(HomeViewModel(
          recentlyPlayed: _createAlbumsFromTracks(recentlyPlayed),
          YourPlaylist: [],
          LocalMusic: [],
        ));
      }
      return AsyncError(error, stack);
    },
  );
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
