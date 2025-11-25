import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/chirp_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/chirp_card.dart';
import 'create_chirp_view.dart';
import 'profile_view.dart';
import 'login_view.dart';
import 'notifications_view.dart';
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeed();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        final chirpViewModel = Provider.of<ChirpViewModel>(
          context,
          listen: false,
        );
        if (!chirpViewModel.isLoading && chirpViewModel.hasMore) {
          chirpViewModel.loadFeed();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    final chirpViewModel = Provider.of<ChirpViewModel>(context, listen: false);
    await chirpViewModel.loadFeed(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chirper',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchView()));
            },
          ),
          // Notifications button with badge
          Consumer<NotificationViewModel>(
            builder: (context, notificationViewModel, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsView(),
                        ),
                      );
                    },
                  ),
                  if (notificationViewModel.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationViewModel.unreadCount > 99
                              ? '99+'
                              : notificationViewModel.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authViewModel = Provider.of<AuthViewModel>(
                context,
                listen: false,
              );
              final navigator = Navigator.of(context);
              await authViewModel.logout();
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateChirpView()),
                );
                if (result == true) {
                  _loadFeed();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Load notifications count when switching to notifications tab
          if (index == 1) {
            final notificationViewModel = Provider.of<NotificationViewModel>(
              context,
              listen: false,
            );
            notificationViewModel.loadUnreadCount();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildFeedTab();
      case 1:
        return const ProfileView();
      default:
        return _buildFeedTab();
    }
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: Consumer<ChirpViewModel>(
        builder: (context, chirpViewModel, child) {
          if (chirpViewModel.isLoading && chirpViewModel.chirps.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chirpViewModel.error != null && chirpViewModel.chirps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error al cargar el feed',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFeed,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (chirpViewModel.chirps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flutter_dash,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡No hay chirps aún!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sé el primero en chirpear',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount:
                chirpViewModel.chirps.length + (chirpViewModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chirpViewModel.chirps.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return ChirpCard(chirp: chirpViewModel.chirps[index]);
            },
          );
        },
      ),
    );
  }
}
