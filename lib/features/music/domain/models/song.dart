class Song {
  final String id;
  final String title;
  final String artist;
  final String albumName;
  final String imageUrl;
  final String duration;
  final bool isPlaying;
  final bool isFavorite;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumName,
    required this.imageUrl,
    required this.duration,
    this.isPlaying = false,
    this.isFavorite = false,
  });
}
