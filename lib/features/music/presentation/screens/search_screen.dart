import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, or albums',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _isSearching = false;
                                });
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                ),
              ),
            ),

            // Search Results or Browse Categories
            if (_isSearching)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Search results will appear here'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final categories = [
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

                    if (index >= categories.length) return null;

                    final category = categories[index];
                    return _CategoryCard(
                      title: category['title'] as String,
                      color: category['color'] as Color,
                      icon: category['icon'] as IconData,
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
          // TODO: Navigate to category page
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
