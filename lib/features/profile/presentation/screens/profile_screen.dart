import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/domain/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).valueOrNull;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'No email';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                photoUrl != null
                                    ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) =>
                                              _buildDefaultAvatar(context),
                                      errorWidget:
                                          (context, url, error) =>
                                              _buildDefaultAvatar(context),
                                    )
                                    : _buildDefaultAvatar(context),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Username
                    Center(
                      child: Text(
                        displayName,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Center(
                      child: Text(
                        email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.favorite,
                      label: 'Favorites',
                      value: '42',
                    ),
                    _StatItem(
                      icon: Icons.playlist_play,
                      label: 'Playlists',
                      value: '12',
                    ),
                    _StatItem(
                      icon: Icons.history,
                      label: 'History',
                      value: '156',
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Settings Sections
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _SettingsSection(
                    title: 'Account',
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {
                          // TODO: Navigate to edit profile
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.music_note,
                        title: 'Creator Dashboard',
                        onTap: () {
                          context.push('/creator-dashboard');
                        },
                      ),
                    ],
                  ),
                  _SettingsSection(
                    title: 'Preferences',
                    items: [
                      _SettingsItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        trailing: 'English',
                        onTap: () {
                          // TODO: Navigate to language settings
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme',
                        trailing: 'Dark',
                        onTap: () {
                          // TODO: Navigate to theme settings
                        },
                      ),
                    ],
                  ),
                  _SettingsSection(
                    title: 'Support',
                    items: [
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () {
                          // TODO: Navigate to help center
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          // TODO: Navigate to about
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Logout Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: () => _showLogoutConfirmation(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            title: Text(
              'Log Out',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to log out?',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(authServiceProvider.notifier).signOut();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        }
      }
    }
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[400]),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        trailing:
            trailing != null
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailing!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                )
                : Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
