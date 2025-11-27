import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/chirp.dart';
import '../services/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  List<User> _users = [];
  List<Chirp> _chirps = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  // Para tabs
  int _selectedTab = 0; // 0 = All, 1 = Users, 2 = Chirps

  List<User> get users => _users;
  List<Chirp> get chirps => _chirps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  int get selectedTab => _selectedTab;
  bool get hasResults => _users.isNotEmpty || _chirps.isNotEmpty;

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  // Search all
  Future<void> searchAll(String query) async {
    if (query.trim().isEmpty) {
      _users = [];
      _chirps = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentQuery = query;
    notifyListeners();

    try {
      final results = await _searchService.searchAll(query);
      _users = results['users'] ?? [];
      _chirps = results['chirps'] ?? [];
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Search only users
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _users = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentQuery = query;
    _chirps = []; // Clear other results
    notifyListeners();

    try {
      _users = await _searchService.searchUsers(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Search only chirps
  Future<void> searchChirps(String query) async {
    if (query.trim().isEmpty) {
      _chirps = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentQuery = query;
    _users = []; // Clear other results
    notifyListeners();

    try {
      _chirps = await _searchService.searchChirps(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _users = [];
    _chirps = [];
    _currentQuery = '';
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
