import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/album.dart';
import '../domain/models/playlist.dart';
import '../domain/models/song.dart';

final homeDataProvider = FutureProvider<HomeViewModel>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Return mock data
  return HomeViewModel(
    recentlyPlayed: _mockRecentlyPlayed(),
    YourPlaylist: _mockYourPlaylist(),
    LocalMusic: _mockLocalMusic(),
  );
});

List<Album> _mockRecentlyPlayed() {
  return [
    Album(
      id: '1',
      title: 'Midnight Memories',
      artist: 'Taylor Swift',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400',
    ),
    Album(
      id: '2',
      title: 'Summer Vibes',
      artist: 'The Weeknd',
      imageUrl:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400',
    ),
    Album(
      id: '3',
      title: 'Acoustic Sessions',
      artist: 'Ed Sheeran',
      imageUrl:
          'https://images.unsplash.com/photo-1516223725307-6f76b9ec8742?q=80&w=400',
    ),
    Album(
      id: '4',
      title: 'Eternal Sunshine',
      artist: 'Ariana Grande',
      imageUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=400',
    ),
  ];
}

List<Playlist> _mockYourPlaylist() {
  return [
    Playlist(
      id: '1',
      title: 'Daily Mix 1',
      description: 'Based on your recent listening',
      imageUrl:
          'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?q=80&w=400',
    ),
    Playlist(
      id: '2',
      title: 'Discover Weekly',
      description: 'Your weekly mixtape of fresh music',
      imageUrl:
          'https://images.unsplash.com/photo-1483412033650-1015ddeb83d1?q=80&w=400',
    ),
  ];
}

List<Song> _mockLocalMusic() {
  return [
    Song(
      id: 'local1',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      albumName: '÷ (Divide)',
      duration: '3:54',
      imageUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=400',
    ),
    Song(
      id: 'local2',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      albumName: 'After Hours',
      duration: '3:20',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400',
    ),
    Song(
      id: 'local3',
      title: 'Dance Monkey',
      artist: 'Tones and I',
      albumName: 'The Kids Are Coming',
      duration: '3:29',
      imageUrl:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400',
    ),
  ];
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
