import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../widgets/chirp_card.dart';
import '../models/user.dart'; // Added import for User model
import 'profile_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        final searchViewModel = Provider.of<SearchViewModel>(
          context,
          listen: false,
        );
        searchViewModel.clearSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );

    switch (_tabController.index) {
      case 0: // All
        searchViewModel.searchAll(query);
        break;
      case 1: // Users
        searchViewModel.searchUsers(query);
        break;
      case 2: // Chirps
        searchViewModel.searchChirps(query);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar usuarios y chirps...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      final searchViewModel = Provider.of<SearchViewModel>(
                        context,
                        listen: false,
                      );
                      searchViewModel.clearSearch();
                    },
                  )
                : null,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (_searchController.text.isNotEmpty) {
              _performSearch(_searchController.text);
            }
          },
          tabs: const [
            Tab(text: 'Todo'),
            Tab(text: 'Usuarios'),
            Tab(text: 'Chirps'),
          ],
        ),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, searchViewModel, child) {
          if (searchViewModel.currentQuery.isEmpty) {
            return _buildEmptyState();
          }

          if (searchViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (searchViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error en la búsqueda',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _performSearch(_searchController.text),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllResults(searchViewModel),
              _buildUsersResults(searchViewModel),
              _buildChirpsResults(searchViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Busca usuarios y chirps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe algo para comenzar',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAllResults(SearchViewModel viewModel) {
    if (!viewModel.hasResults) {
      return _buildNoResults();
    }

    return ListView(
      children: [
        if (viewModel.users.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Usuarios',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...viewModel.users.take(3).map((user) => UserListItem(user: user)),
          if (viewModel.users.length > 3)
            TextButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text('Ver todos los usuarios'),
            ),
          const Divider(),
        ],
        if (viewModel.chirps.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Chirps',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...viewModel.chirps.map((chirp) => ChirpCard(chirp: chirp)),
        ],
      ],
    );
  }

  Widget _buildUsersResults(SearchViewModel viewModel) {
    if (viewModel.users.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      itemCount: viewModel.users.length,
      itemBuilder: (context, index) {
        return UserListItem(user: viewModel.users[index]);
      },
    );
  }

  Widget _buildChirpsResults(SearchViewModel viewModel) {
    if (viewModel.chirps.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      itemCount: viewModel.chirps.length,
      itemBuilder: (context, index) {
        return ChirpCard(chirp: viewModel.chirps[index]);
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra búsqueda',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final User user;

  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        backgroundImage: user.fullProfileImageUrl != null
            ? NetworkImage(user.fullProfileImageUrl!)
            : null,
        child: user.fullProfileImageUrl == null
            ? Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.displayName ?? user.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${user.username}'),
          if (user.bio != null)
            Text(
              user.bio!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${user.followersCount} seguidores',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileView(user: user),
          ),
        );
      },
    );
  }
}
