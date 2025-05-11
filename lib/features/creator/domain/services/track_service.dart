import 'dart:io';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../models/track.dart';

final trackServiceProvider = Provider<TrackService>((ref) => TrackService());

class TrackService {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<Track> uploadTrack({
    required File audioFile,
    required File coverArtFile,
    required String title,
    required String artist,
    required String genre,
    String? album,
    required String userId,
  }) async {
    try {
      dev.log('Starting track upload');
      dev.log(
          'Audio file: ${audioFile.path}, size: ${await audioFile.length()} bytes');
      dev.log(
          'Cover art file: ${coverArtFile.path}, size: ${await coverArtFile.length()} bytes');

      // Generate unique file names
      final audioFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(audioFile.path)}';
      final coverArtFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(coverArtFile.path)}';

      dev.log(
          'Generated file names: Audio: $audioFileName, Cover: $coverArtFileName');

      // Create references
      final audioRef = _storage.ref().child('tracks/$userId/$audioFileName');
      final coverArtRef =
          _storage.ref().child('cover_art/$userId/$coverArtFileName');

      dev.log('Starting audio file upload');

      try {
        // Upload audio file with metadata
        final metadata = SettableMetadata(
          contentType: _getContentType(audioFile.path),
          customMetadata: {
            'title': title,
            'artist': artist,
            'genre': genre,
            if (album != null) 'album': album,
          },
        );

        // Use putFile with metadata
        final audioUploadTask = audioRef.putFile(audioFile, metadata);

        // Monitor progress
        audioUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          dev.log(
              'Audio upload progress: ${(progress * 100).toStringAsFixed(2)}%');
        });

        // Wait for upload to complete
        await audioUploadTask
            .whenComplete(() => dev.log('Audio upload completed'));
        final audioUrl = await audioRef.getDownloadURL();
        dev.log('Audio URL: $audioUrl');

        dev.log('Starting cover art upload');

        // Upload cover art with metadata
        final coverMetadata = SettableMetadata(
          contentType: _getContentType(coverArtFile.path),
          customMetadata: {
            'title': title,
            'artist': artist,
          },
        );

        // Use putFile with metadata
        final coverArtUploadTask =
            coverArtRef.putFile(coverArtFile, coverMetadata);

        // Monitor progress
        coverArtUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          dev.log(
              'Cover art upload progress: ${(progress * 100).toStringAsFixed(2)}%');
        });

        // Wait for upload to complete
        await coverArtUploadTask
            .whenComplete(() => dev.log('Cover art upload completed'));
        final coverArtUrl = await coverArtRef.getDownloadURL();
        dev.log('Cover art URL: $coverArtUrl');

        // Create track document
        dev.log('Creating Firestore document');
        final trackRef = _firestore.collection('tracks').doc();
        final now = DateTime.now();

        final track = Track(
          id: trackRef.id,
          title: title,
          artist: artist,
          genre: genre,
          album: album,
          storageUrl: audioUrl,
          coverArtUrl: coverArtUrl,
          userId: userId,
          createdAt: now,
          updatedAt: now,
        );

        // Convert to JSON
        final trackJson = track.toJson();
        dev.log('Track JSON: $trackJson');

        // Save to Firestore
        dev.log('Saving to Firestore');
        await trackRef.set(trackJson);
        dev.log('Upload process completed successfully');

        return track;
      } catch (storageError) {
        dev.log('Storage error: $storageError', error: storageError);
        // Try to clean up any failed uploads
        try {
          await audioRef
              .delete()
              .catchError((e) => dev.log('Failed to delete audio: $e'));
          await coverArtRef
              .delete()
              .catchError((e) => dev.log('Failed to delete cover: $e'));
        } catch (cleanupError) {
          dev.log('Error during cleanup: $cleanupError');
        }
        throw Exception('Storage operation failed: $storageError');
      }
    } catch (e) {
      dev.log('Failed to upload track: $e', error: e);
      throw Exception('Failed to upload track: $e');
    }
  }

  String _getContentType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.flac':
        return 'audio/flac';
      case '.mov':
        return 'video/quicktime';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Stream<List<Track>> getUserTracks(String userId) {
    return _firestore
        .collection('tracks')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final tracks =
          snapshot.docs.map((doc) => Track.fromFirestore(doc)).toList();
      // Sort tracks by createdAt in memory instead of in the query
      tracks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tracks;
    });
  }

  Future<void> deleteTrack(String trackId) async {
    await _firestore.collection('tracks').doc(trackId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
