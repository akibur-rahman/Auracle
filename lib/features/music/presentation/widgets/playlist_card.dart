import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.width = 150,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: playlist.imageUrl,
              width: width,
              height: width,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: width,
                    height: width,
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: width,
                    height: width,
                    color: Colors.grey[900],
                    child: const Icon(Icons.error),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: width,
            child: Text(
              playlist.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width,
            child: Text(
              playlist.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
