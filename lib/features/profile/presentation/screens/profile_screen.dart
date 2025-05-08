import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://scontent.fdac19-1.fna.fbcdn.net/v/t39.30808-6/488600335_2494024400947599_5749715298796060550_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeGTvCJhJ3E0zKI3J16fMqexdYuElq4iqeh1i4SWriKp6MTlxW6Z-xrPYg2jLaE7zaGNOEFbjtxM-w03VkKm_qwz&_nc_ohc=k5U2xhGhpgEQ7kNvwFHfm9y&_nc_oc=AdkveqfPCltjDN62XezqpefGD68ZCgx8oyRcUlOnjt_Au6yKX5akcbluLsqkqWIWC1I&_nc_zt=23&_nc_ht=scontent.fdac19-1.fna&_nc_gid=Q6U0aWgqspIxTYcOndwdMg&oh=00_AfLlookkV9ids8uwaZ7_jbNXJXgYxvXffO-49n7hgPMPQQ&oe=682271E9',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    width: 100,
                                    height: 100,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: 100,
                                    height: 100,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
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
                        'Akibur Rohman',
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
                        'me.akiburrahman@gmail.com',
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

            // Settings Section
            SliverList(
              delegate: SliverChildListDelegate([
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
                const SizedBox(height: 24),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Log Out'),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
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
