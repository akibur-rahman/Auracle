import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/album.dart';
import '../domain/models/playlist.dart';
import '../domain/models/song.dart';
import 'tracks_provider.dart';
import 'player_provider.dart';

final homeDataProvider = FutureProvider<HomeViewModel>((ref) async {
  // Get the recently played tracks from the provider
  final recentlyPlayed = ref.watch(recentlyPlayedProvider);

  // If there are no recently played tracks, get some tracks from the database
  final recentAlbums = recentlyPlayed.isNotEmpty
      ? _createAlbumsFromTracks(recentlyPlayed)
      : await _getFallbackAlbums(ref);

  // Get real playlists (empty list for now, will be populated from Firebase in future)
  final playlists = <Playlist>[];

  // Return data
  return HomeViewModel(
    recentlyPlayed: recentAlbums,
    YourPlaylist: playlists,
    LocalMusic: [], // No local music for now
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

// Fallback to get some albums if no recently played tracks
Future<List<Album>> _getFallbackAlbums(Ref ref) async {
  try {
    final tracks = await ref.watch(tracksProvider.future);
    return _createAlbumsFromTracks(tracks);
  } catch (e) {
    return []; // Return empty list if there's an error
  }
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
