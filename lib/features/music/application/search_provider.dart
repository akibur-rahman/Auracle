import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import 'tracks_provider.dart';

// Provider to store the current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for search results using caseInsensitiveContains matching
final searchResultsProvider = FutureProvider<List<Song>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  // If query is empty, return empty list
  if (query.trim().isEmpty) {
    return [];
  }

  try {
    final searchTerm = query.toLowerCase();
    final artistMatches = <String>{};
    final songResults = <Song>[];
    final songIds = <String>{};

    // Get all tracks from Firestore
    // Note: In a production app with thousands of tracks,
    // you'd implement server-side search or use Algolia/Elasticsearch
    final tracksSnapshot = await FirebaseFirestore.instance
        .collection('tracks')
        .where('isDeleted', isEqualTo: false)
        .get();

    // First pass: Find direct song matches and collect matching artists
    for (final doc in tracksSnapshot.docs) {
      final data = doc.data();
      final title = data['title']?.toString().toLowerCase() ?? '';
      final artist = data['artist']?.toString().toLowerCase() ?? '';
      final album = data['album']?.toString().toLowerCase() ?? '';

      // Check if this song matches the search query
      final isTitleMatch = title.contains(searchTerm);
      final isArtistMatch = artist.contains(searchTerm);
      final isAlbumMatch = album.contains(searchTerm);

      // If the artist matches, remember it for second pass
      if (isArtistMatch) {
        artistMatches.add(artist);
      }

      // Add direct matches to results
      if (isTitleMatch || isArtistMatch || isAlbumMatch) {
        final song = trackToSong(doc);
        // Only add if not already in results (avoid duplicates)
        if (!songIds.contains(song.id)) {
          songResults.add(song);
          songIds.add(song.id);
        }
      }
    }

    // Second pass: Find songs by matching artists not already in results
    if (artistMatches.isNotEmpty) {
      for (final doc in tracksSnapshot.docs) {
        final data = doc.data();
        final artist = data['artist']?.toString().toLowerCase() ?? '';

        if (artistMatches.contains(artist)) {
          final song = trackToSong(doc);
          // Only add if not already in results
          if (!songIds.contains(song.id)) {
            songResults.add(song);
            songIds.add(song.id);
          }
        }
      }
    }

    return songResults;
  } catch (e) {
    dev.log('Error searching tracks: $e');
    return [];
  }
});

// Helper function to convert Firestore document to Song model
Song trackToSong(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Song(
    id: doc.id,
    title: data['title'] ?? 'Unknown Title',
    artist: data['artist'] ?? 'Unknown Artist',
    albumName: data['album'] ?? '',
    imageUrl: data['coverArtUrl'] ?? '',
    duration: '3:45', // Default duration since not included in data
    storageUrl: data['storageUrl'],
  );
}
