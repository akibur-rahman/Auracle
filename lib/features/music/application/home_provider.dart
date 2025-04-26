import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/album.dart';
import '../domain/models/playlist.dart';

final homeDataProvider = FutureProvider<HomeViewModel>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Return mock data
  return HomeViewModel(
    recentlyPlayed: _mockRecentlyPlayed(),
    madeForYou: _mockMadeForYou(),
    popularPlaylists: _mockPopularPlaylists(),
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

List<Playlist> _mockMadeForYou() {
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

List<Playlist> _mockPopularPlaylists() {
  return [
    Playlist(
      id: '3',
      title: 'Top Hits 2023',
      description: 'The biggest hits of the year',
      imageUrl:
          'https://images.unsplash.com/photo-1669173034860-eca2e1ee62b2?q=80&w=400',
    ),
    Playlist(
      id: '4',
      title: 'Chill Vibes',
      description: 'Perfect for relaxing',
      imageUrl:
          'https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?q=80&w=400',
    ),
    Playlist(
      id: '5',
      title: 'Workout Beats',
      description: 'Energy boosting tracks',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=400',
    ),
    Playlist(
      id: '6',
      title: 'Throwback Classics',
      description: 'Hits from the 90s and 00s',
      imageUrl:
          'https://images.unsplash.com/photo-1458560871784-56d23406c091?q=80&w=400',
    ),
  ];
}

class HomeViewModel {
  final List<Album> recentlyPlayed;
  final List<Playlist> madeForYou;
  final List<Playlist> popularPlaylists;

  HomeViewModel({
    required this.recentlyPlayed,
    required this.madeForYou,
    required this.popularPlaylists,
  });
}
