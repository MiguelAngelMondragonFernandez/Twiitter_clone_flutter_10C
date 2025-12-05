import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/chirp_viewmodel.dart';
import '../widgets/chirp_card.dart';
import '../services/auth_service.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  final User? user; // User being viewed (can be null for current user's profile)

  const ProfileView({super.key, this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Local state for the user being displayed to allow for optimistic UI updates
  late User _profileUser;
  bool _isCurrentUserProfile = false;

  @override
  void initState() {
    super.initState();

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Determine if this is the logged-in user's own profile
    _isCurrentUserProfile = widget.user == null || widget.user!.id == authViewModel.currentUser?.id;

    // Initialize the local user state
    _profileUser = widget.user ?? authViewModel.currentUser!;
    
    // Fetch fresh user data from backend
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshUserData();
      
      // Fetch user's chirps
      if (mounted) {
        final chirpViewModel = Provider.of<ChirpViewModel>(context, listen: false);
        chirpViewModel.loadUserChirps(_profileUser.id);
      }
    });
  }

  Future<void> _refreshUserData() async {
    final authService = AuthService();
    User? updatedUser;
    
    if (_isCurrentUserProfile) {
      // For current user, fetch from profile endpoint
      updatedUser = await authService.fetchUserProfile();
    } else {
      // For other users, fetch by ID
      updatedUser = await authService.getUserById(_profileUser.id);
    }
    
    if (updatedUser != null && mounted) {
      setState(() {
        _profileUser = updatedUser!;
      });
    }
  }

  bool _isFollowLoading = false;

  Future<void> _toggleFollow() async {
    if (_isFollowLoading) return; // Prevent multiple simultaneous calls
    
    final authService = AuthService();
    final currentFollowState = _profileUser.isFollowing;
    
    // Show loading state
    setState(() {
      _isFollowLoading = true;
      _profileUser = _profileUser.copyWith(isFollowing: !currentFollowState);
    });
    
    // Call the appropriate service method
    final result = currentFollowState
        ? await authService.unfollowUser(_profileUser.id)
        : await authService.followUser(_profileUser.id);
    
    // Use the updated user from the response
    if (result['success'] == true && result['user'] != null) {
      setState(() {
        _profileUser = result['user'];
        _isFollowLoading = false;
      });
      
      // Also, refresh the main feed so the changes are reflected there
      if (mounted) {
        Provider.of<ChirpViewModel>(context, listen: false).loadFeed(refresh: true);
      }
    } else {
      // Revert on failure
      setState(() {
        _profileUser = _profileUser.copyWith(isFollowing: currentFollowState);
        _isFollowLoading = false;
      });
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ocurrió un error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The main consumer is now for the chirps, as user data is handled in local state.
    return Scaffold(
      appBar: AppBar(
        title: Text(_profileUser.displayName ?? _profileUser.username),
        actions: [
          if (!_isCurrentUserProfile)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: _buildFollowButton(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileView(user: _profileUser),
                    ),
                  ).then((_) {
                    // Refresh profile when returning from edit
                    setState(() {
                      // Trigger a rebuild or re-fetch if needed
                      // For now, the viewmodel might be updated via notifyListeners
                    });
                  });
                },
                child: const Text('Editar perfil'),
              ),
            ),
        ],
      ),
      body: Consumer<ChirpViewModel>(
        builder: (context, chirpViewModel, child) {
          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),

              // User's chirps
              if (chirpViewModel.isUserProfileLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (chirpViewModel.userProfileError != null)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error al cargar chirps',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else if (chirpViewModel.userProfileChirps.isEmpty)
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
                          'Aún no hay chirps',
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ChirpCard(chirp: chirpViewModel.userProfileChirps[index]);
                    },
                    childCount: chirpViewModel.userProfileChirps.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFollowButton() {
    if (_profileUser.isFollowing) {
      return OutlinedButton(
        onPressed: _toggleFollow,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
        ),
        child: const Text('Dejar de seguir'),
      );
    } else {
      return ElevatedButton(
        onPressed: _toggleFollow,
        child: const Text('Seguir'),
      );
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
            backgroundImage: _profileUser.fullProfileImageUrl != null
                ? NetworkImage(_profileUser.fullProfileImageUrl!)
                : null,
            child: _profileUser.fullProfileImageUrl == null
                ? Text(
                    _profileUser.username[0].toUpperCase(),
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
            _profileUser.displayName ?? _profileUser.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${_profileUser.username}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          // Location
          if ((_profileUser.city != null && _profileUser.city!.isNotEmpty) ||
              (_profileUser.country != null && _profileUser.country!.isNotEmpty)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  [
                    if (_profileUser.city != null && _profileUser.city!.isNotEmpty) _profileUser.city,
                    if (_profileUser.country != null && _profileUser.country!.isNotEmpty) _profileUser.country,
                  ].join(', '),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ],

          // Bio
          if (_profileUser.bio != null && _profileUser.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_profileUser.bio!, style: const TextStyle(fontSize: 15)),
          ],

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _StatItem(
                count: _profileUser.followingCount,
                label: 'Siguiendo',
              ),
              const SizedBox(width: 24),
              _StatItem(
                count: _profileUser.followersCount,
                label: 'Seguidores',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
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
