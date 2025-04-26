import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/mini_player.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final bool showMiniPlayer;

  const LibraryScreen({super.key, this.showMiniPlayer = true});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Playlists', 'Artists', 'Albums'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: Colors.black,
                    title: const Text(
                      'Your Library',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF282828),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  // Tabs
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              _tabs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final title = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(title),
                                    selected: _selectedTabIndex == index,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedTabIndex = index;
                                      });
                                    },
                                    backgroundColor: const Color(0xFF282828),
                                    selectedColor: Colors.white,
                                    checkmarkColor: Colors.black,
                                    labelStyle: TextStyle(
                                      color:
                                          _selectedTabIndex == index
                                              ? Colors.black
                                              : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Playlists
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildPlaylistItem(
                        title: 'Liked Songs',
                        subtitle: '238 songs',
                        imageUrl:
                            'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400',
                      ),
                      _buildPlaylistItem(
                        title: 'Your Top Songs 2023',
                        subtitle: '100 songs',
                        imageUrl:
                            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400',
                      ),
                      _buildPlaylistItem(
                        title: 'Discover Weekly',
                        subtitle: '30 songs • Updated weekly',
                        imageUrl:
                            'https://images.unsplash.com/photo-1516223725307-6f76b9ec8742?q=80&w=400',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            // Mini Player
            if (widget.showMiniPlayer) const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistItem({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.music_note),
                  ),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),

          // Arrow
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
