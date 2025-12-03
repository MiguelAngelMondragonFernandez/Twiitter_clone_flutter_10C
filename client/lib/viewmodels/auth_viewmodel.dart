import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // --- FIX: NO HACER notifyListeners() DURANTE EL BUILD ---
  Future<void> checkAuthStatus() async {
    _isLoading = true;

    // 🔥 Disparamos el notify después del build
    Future.microtask(() => notifyListeners());

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // Verify token with backend
        final user = await _authService.fetchUserProfile();
        if (user != null) {
          _currentUser = user;
        } else {
          // Token invalid/expired, logout handled in fetchUserProfile or here
          _currentUser = null;
        }
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    }

    _isLoading = false;

    // 🔥 Nuevo notify seguro
    Future.microtask(() => notifyListeners());
  }

  // ---------------------------------------------------------

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _currentUser = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(username, email, password);

      if (result['success']) {
        _currentUser = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> follow(String userId) async {
    if (_currentUser == null || userId == _currentUser!.id) return false;

    final originalUser = _currentUser;
    // Optimistic update
    _currentUser = _currentUser!.copyWith(
      followingCount: _currentUser!.followingCount + 1,
    );
    notifyListeners();

    try {
      await _authService.followUser(userId);
      // NOTE: Here we could re-fetch the user or update from a successful response
      // to ensure data consistency with the backend, but for now this is fine.
      return true;
    } catch (e) {
      // Revert on error
      _currentUser = originalUser;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfollow(String userId) async {
    if (_currentUser == null || userId == _currentUser!.id) return false;

    final originalUser = _currentUser;
    // Optimistic update
    _currentUser = _currentUser!.copyWith(
      followingCount: _currentUser!.followingCount > 0 ? _currentUser!.followingCount - 1 : 0,
    );
    notifyListeners();

    try {
      await _authService.unfollowUser(userId);
      return true;
    } catch (e) {
      // Revert on error
      _currentUser = originalUser;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile(String displayName, String bio, {String? imagePath, String? city, String? country}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(displayName, bio, imagePath: imagePath, city: city, country: country);
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
