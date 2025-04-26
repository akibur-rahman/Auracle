class Album {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final bool isPlaying;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    this.isPlaying = false,
  });
}
