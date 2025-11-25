import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/chirp.dart';
import '../viewmodels/chirp_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/create_chirp_view.dart';

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
          // Navigate to chirp detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    backgroundImage: chirp.author.profileImageUrl != null
                        ? NetworkImage(chirp.author.profileImageUrl!)
                        : null,
                    child: chirp.author.profileImageUrl == null
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
                            Text(
                              chirp.author.displayName ?? chirp.author.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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

              // Content
              Text(chirp.content, style: const TextStyle(fontSize: 15)),
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
                          builder: (context) => CreateChirpView(
                            replyToId: chirp.id,
                          ),
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
                    onTap: () {
                      chirpViewModel.toggleLike(chirp.id);
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
