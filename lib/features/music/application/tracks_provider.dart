import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../domain/models/song.dart';
import '../../../features/creator/domain/models/track.dart';

part 'tracks_provider.g.dart';

// Stream-based provider that listens to Firestore changes in real-time
final tracksStreamProvider = StreamProvider<List<Song>>((ref) {
  // Initialize with a value from the simpler provider to avoid loading forever
  ref.listenSelf((previous, next) {
    if (next is AsyncLoading && previous == null) {
      // On first load, immediately fetch some tracks with the simpler future provider
      ref.read(tracksProvider);
    }
  });

  try {
    return FirebaseFirestore.instance
        .collection('tracks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .handleError((e) {
      dev.log('Error in tracksStreamProvider: $e');
      if (e.toString().contains('index')) {
        dev.log('Missing index, using fallback query without ordering');
        // Return a simpler query that doesn't require the composite index
        return FirebaseFirestore.instance
            .collection('tracks')
            .limit(5)
            .snapshots();
      }
      throw e;
    }).map((snapshot) {
      final tracks = snapshot.docs
          .map((doc) => trackToSong(Track.fromFirestore(doc)))
          .toList();
      return tracks;
    });
  } catch (e) {
    dev.log('Fallback to simple query in tracksStreamProvider: $e');
    // Fallback to a very simple query if all else fails
    return FirebaseFirestore.instance
        .collection('tracks')
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => trackToSong(Track.fromFirestore(doc)))
          .toList();
    });
  }
});

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

// Stream-based provider for all tracks
final allTracksStreamProvider = StreamProvider<List<Song>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('tracks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      dev.log('Error in allTracksStreamProvider: $e');
      if (e.toString().contains('index')) {
        dev.log('Missing index, using fallback query without ordering');
        // Return a simpler query that doesn't require the composite index
        return FirebaseFirestore.instance.collection('tracks').snapshots();
      }
      throw e;
    }).map((snapshot) {
      final docs = snapshot.docs;
      // Sort in memory instead since we can't use Firestore ordering
      final tracks = docs
          .map((doc) => trackToSong(Track.fromFirestore(doc)))
          .toList()
        ..sort((a, b) =>
            b.id.compareTo(a.id)); // Approximate sort by creation time
      return tracks;
    });
  } catch (e) {
    dev.log('Fallback to simple query in allTracksStreamProvider: $e');
    // Fallback to a very simple query if all else fails
    return FirebaseFirestore.instance
        .collection('tracks')
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;
      final tracks = docs
          .map((doc) => trackToSong(Track.fromFirestore(doc)))
          .toList()
        ..sort((a, b) => b.id.compareTo(a.id)); // Approximate sort
      return tracks;
    });
  }
});

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
