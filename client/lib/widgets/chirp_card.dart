import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/chirp.dart';
import '../viewmodels/chirp_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/create_chirp_view.dart';
import '../views/chirp_detail_view.dart';
import '../utils/api_constants.dart';

class ChirpCard extends StatelessWidget {
  final Chirp chirp;

  const ChirpCard({super.key, required this.chirp});

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final chirpViewModel = Provider.of<ChirpViewModel>(context, listen: false);
    final isOwnChirp = authViewModel.currentUser?.id == chirp.author.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChirpDetailView(chirp: chirp),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repost Indicator
              if (chirp.repostedBy != null) ...[
                Row(
                  children: [
                    const SizedBox(width: 32), // Align with content
                    Icon(Icons.repeat, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Reposteado por ${chirp.repostedBy!.displayName ?? chirp.repostedBy!.username}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    backgroundImage: chirp.author.fullProfileImageUrl != null
                        ? NetworkImage(chirp.author.fullProfileImageUrl!)
                        : null,
                    child: chirp.author.fullProfileImageUrl == null
                        ? Text(
                            chirp.author.username[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                chirp.author.displayName ?? chirp.author.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '@${chirp.author.username}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '· ${_formatTimestamp(chirp.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(chirp.content, style: const TextStyle(fontSize: 15)),
                        if (chirp.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: chirp.imageUrls.length,
                              itemBuilder: (context, index) {
                                final imageUrl = chirp.imageUrls[index].startsWith('http')
                                    ? chirp.imageUrls[index]
                                    : '${ApiConstants.serverUrl}${chirp.imageUrls[index]}';
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isOwnChirp)
                    PopupMenuButton(
                      icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                          onTap: () {
                            _showDeleteDialog(context, chirpViewModel);
                          },
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    count: chirp.repliesCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChirpDetailView(chirp: chirp),
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    icon: Icons.repeat,
                    count: chirp.repostsCount,
                    isActive: chirp.isReposted,
                    activeColor: Colors.green,
                    onTap: () {
                      chirpViewModel.repostChirp(chirp.id);
                    },
                  ),
                  _ActionButton(
                    icon: chirp.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    count: chirp.likesCount,
                    isActive: chirp.isLiked,
                    activeColor: Colors.red,
                    onTap: () async {
                      final error = await chirpViewModel.toggleLike(chirp.id);
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    },
                  ),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    count: 0,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compartir no implementado')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChirpViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Chirp'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este chirp?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteChirp(chirp.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.count,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive && activeColor != null
        ? activeColor
        : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(color: color, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
