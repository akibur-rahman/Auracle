import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../domain/models/song.dart';
import '../../../features/creator/domain/models/track.dart';

part 'tracks_provider.g.dart';

// Provider for fetching a limited number of tracks (5) for the home screen
@riverpod
Future<List<Song>> tracks(TracksRef ref) async {
  try {
    final tracksSnapshot = await FirebaseFirestore.instance
        .collection('tracks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return tracksSnapshot.docs
        .map((doc) => trackToSong(Track.fromFirestore(doc)))
        .toList();
  } catch (e) {
    dev.log('Error fetching tracks: $e');

    // If the error contains 'index', it's likely the missing index error
    if (e.toString().contains('index')) {
      dev.log(
          'Missing Firestore index. Please create the index using the link in the error message.');

      // Fallback: fetch without ordering for now, which doesn't require the composite index
      try {
        final tracksSnapshot = await FirebaseFirestore.instance
            .collection('tracks')
            .limit(5)
            .get();

        return tracksSnapshot.docs
            .map((doc) => trackToSong(Track.fromFirestore(doc)))
            .toList();
      } catch (fallbackError) {
        dev.log('Fallback query also failed: $fallbackError');
        return []; // Return empty list as last resort
      }
    }

    // Re-throw if it's not an index error
    rethrow;
  }
}

// Provider for fetching all tracks
@riverpod
Future<List<Song>> allTracks(AllTracksRef ref) async {
  try {
    final tracksSnapshot = await FirebaseFirestore.instance
        .collection('tracks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return tracksSnapshot.docs
        .map((doc) => trackToSong(Track.fromFirestore(doc)))
        .toList();
  } catch (e) {
    dev.log('Error fetching all tracks: $e');

    // If the error contains 'index', it's likely the missing index error
    if (e.toString().contains('index')) {
      dev.log(
          'Missing Firestore index. Please create the index using the link in the error message.');

      // Fallback: fetch without ordering or filtering, which doesn't require the composite index
      try {
        final tracksSnapshot =
            await FirebaseFirestore.instance.collection('tracks').get();

        return tracksSnapshot.docs
            .map((doc) => trackToSong(Track.fromFirestore(doc)))
            .toList();
      } catch (fallbackError) {
        dev.log('Fallback query also failed: $fallbackError');
        return []; // Return empty list as last resort
      }
    }

    // Re-throw if it's not an index error
    rethrow;
  }
}

// Helper function to convert Track to Song
Song trackToSong(Track track) {
  return Song(
    id: track.id,
    title: track.title,
    artist: track.artist,
    albumName: track.album ?? '',
    imageUrl: track.coverArtUrl,
    // Format duration or use a placeholder (since Track doesn't have duration)
    duration: '3:45',
    isPlaying: false,
    isFavorite: false,
    storageUrl: track.storageUrl,
  );
}
