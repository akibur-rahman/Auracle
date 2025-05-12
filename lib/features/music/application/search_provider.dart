import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../domain/models/song.dart';
import 'tracks_provider.dart';

// The minimum score a result needs to be considered a match
const int _minFuzzyScore = 60;

final searchResultsProvider =
    StateNotifierProvider<SearchResultsNotifier, List<Song>>((ref) {
  return SearchResultsNotifier(ref);
});

class SearchResultsNotifier extends StateNotifier<List<Song>> {
  final Ref ref;

  SearchResultsNotifier(this.ref) : super([]);

  void search(String query) {
    if (query.isEmpty) {
      state = [];
      return;
    }

    // Get all songs from the tracksStreamProvider
    final tracks = ref.read(tracksStreamProvider).valueOrNull ?? [];

    // Set to track already added songs to avoid duplicates
    final Set<String> addedSongIds = {};
    final List<Song> results = [];

    // Convert query to lowercase for case-insensitive comparison
    final lowercaseQuery = query.toLowerCase();

    // First, add exact matches for song title with higher priority
    for (final song in tracks) {
      final lowercaseTitle = song.title.toLowerCase();

      // Direct contains match for song title (highest priority)
      if (lowercaseTitle.contains(lowercaseQuery) &&
          !addedSongIds.contains(song.id)) {
        results.add(song);
        addedSongIds.add(song.id);
      }
    }

    // Next, add exact matches for artist name
    for (final song in tracks) {
      final lowercaseArtist = song.artist.toLowerCase();

      // Direct contains match for artist
      if (lowercaseArtist.contains(lowercaseQuery) &&
          !addedSongIds.contains(song.id)) {
        results.add(song);
        addedSongIds.add(song.id);
      }
    }

    // Finally, use fuzzy matching for anything that might have been missed
    for (final song in tracks) {
      // Skip songs already added
      if (addedSongIds.contains(song.id)) continue;

      // Get fuzzy match scores
      final titleScore = partialRatio(query, song.title);
      final artistScore = partialRatio(query, song.artist);

      // Use the better of the two scores
      final bestScore = titleScore > artistScore ? titleScore : artistScore;

      // Add to results if score is high enough
      if (bestScore >= _minFuzzyScore) {
        results.add(song);
        addedSongIds.add(song.id);
      }
    }

    state = results;
  }
}
