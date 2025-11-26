import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/chirp_viewmodel.dart';
import '../widgets/chirp_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final chirpViewModel = Provider.of<ChirpViewModel>(
        context,
        listen: false,
      );

      if (authViewModel.currentUser != null) {
        chirpViewModel.loadUserChirps(authViewModel.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, ChirpViewModel>(
      builder: (context, authViewModel, chirpViewModel, child) {
        final user = authViewModel.currentUser;

        if (user == null) {
          return const Center(child: Text('No hay usuario autenticado'));
        }

        return CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Text(
                              user.username[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Name and username
                    Text(
                      user.displayName ?? user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // Bio
                    if (user.bio != null) ...[
                      const SizedBox(height: 12),
                      Text(user.bio!, style: const TextStyle(fontSize: 15)),
                    ],

                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        _StatItem(
                          count: user.followingCount,
                          label: 'Siguiendo',
                        ),
                        const SizedBox(width: 24),
                        _StatItem(
                          count: user.followersCount,
                          label: 'Seguidores',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                  ],
                ),
              ),
            ),

            // User's chirps
            if (chirpViewModel.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (chirpViewModel.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error al cargar chirps',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else if (chirpViewModel.chirps.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No has chirpeado aún',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ChirpCard(chirp: chirpViewModel.chirps[index]);
                }, childCount: chirpViewModel.chirps.length),
              ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ],
    );
  }
}
