import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/tracks_provider.dart';
import '../widgets/track_list.dart';
import '../widgets/mini_player.dart';

class AllTracksScreen extends ConsumerWidget {
  const AllTracksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTracksAsync = ref.watch(allTracksProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('All Tracks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: allTracksAsync.when(
                data: (tracks) => tracks.isEmpty
                    ? _buildEmptyState(context)
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TrackList(songs: tracks),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildError(context, error),
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No tracks available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tracks you upload will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Error loading tracks\n',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red,
                    ),
              ),
              TextSpan(
                text: error.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
