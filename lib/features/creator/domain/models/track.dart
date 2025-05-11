import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

part 'track.freezed.dart';
part 'track.g.dart';

@freezed
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String artist,
    required String genre,
    String? album,
    required String storageUrl,
    required String coverArtUrl,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int playCount,
    @Default(false) bool isDeleted,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  factory Track.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // Convert Timestamps to DateTime
      DateTime createdAt;
      DateTime updatedAt;

      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt'] as String);
      } else {
        createdAt = DateTime.now();
        dev.log('Warning: createdAt field is neither Timestamp nor String');
      }

      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else if (data['updatedAt'] is String) {
        updatedAt = DateTime.parse(data['updatedAt'] as String);
      } else {
        updatedAt = DateTime.now();
        dev.log('Warning: updatedAt field is neither Timestamp nor String');
      }

      // Create a new map with all the original data but with parsed dates
      final jsonData = {
        'id': doc.id,
        ...data,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

      return Track.fromJson(jsonData);
    } catch (e) {
      dev.log('Error parsing Firestore document: $e', error: e);
      rethrow;
    }
  }
}

// Helper extension to convert Track to Firestore format
extension TrackFirestoreX on Track {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Remove 'id' as Firestore will assign its own document ID
    json.remove('id');

    // Convert DateTime to Timestamp
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);

    return json;
  }
}
