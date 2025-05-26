import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/search_provider.dart';
import '../../application/player_provider.dart';
import '../widgets/mini_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous search query when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, or albums',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
              ),
            ),

            // Search Results or Browse Categories
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(searchResults)
                  : _buildBrowseCategories(),
            ),

            // Mini Player
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<dynamic>> searchResults) {
    return searchResults.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final song = results[index];
            return _buildSearchResultItem(song);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading search results: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(dynamic song) {
    final controls = ref.read(playerControlsProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(
          imageUrl: song.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        onPressed: () async {
          // Get all tracks to use as queue
          final allTracks = await ref.read(searchResultsProvider.future);

          // Set up queue and play song
          await controls.playWithQueue(
              song, allTracks, allTracks.indexOf(song));

          // Update search history (could be implemented later)
        },
      ),
      onTap: () async {
        // Same functionality as the play button
        final allTracks = await ref.read(searchResultsProvider.future);
        await controls.playWithQueue(song, allTracks, allTracks.indexOf(song));
      },
    );
  }

  Widget _buildBrowseCategories() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _CategoryCard(
          title: category['title'] as String,
          color: category['color'] as Color,
          icon: category['icon'] as IconData,
        );
      },
    );
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Pop',
      'color': Colors.pink,
      'icon': Icons.music_note,
    },
    {
      'title': 'Rock',
      'color': Colors.red,
      'icon': Icons.music_note,
    },
    {
      'title': 'Hip Hop',
      'color': Colors.purple,
      'icon': Icons.headphones,
    },
    {
      'title': 'Jazz',
      'color': Colors.blue,
      'icon': Icons.piano,
    },
    {
      'title': 'Classical',
      'color': Colors.teal,
      'icon': Icons.audiotrack,
    },
    {
      'title': 'Electronic',
      'color': Colors.orange,
      'icon': Icons.electrical_services,
    },
  ];
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;

  const _CategoryCard({
    required this.title,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.8),
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () {
          // Set search query to category name for a quick search
          final container = ProviderScope.containerOf(context);
          container.read(searchQueryProvider.notifier).state = title;
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32.0, color: Colors.white),
              const SizedBox(height: 8.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
