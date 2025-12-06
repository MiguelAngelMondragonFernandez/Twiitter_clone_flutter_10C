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

  AuthViewModel() {
    _initAuthState();
  }

  // Initialize auth state from stored data
  Future<void> _initAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is logged in by checking stored token
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        // Try to fetch user profile from backend
        _currentUser = await _authService.fetchUserProfile();
        
        // If fetch fails (e.g., token expired), get stored user
        _currentUser ??= await _authService.getStoredUser();
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        _currentUser = await _authService.fetchUserProfile();
        
        _currentUser ??= await _authService.getStoredUser();
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();

      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Error al iniciar sesión con Google';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
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

      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Error al registrarse';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> follow(String userId) async {
    if (_currentUser == null || userId == _currentUser!.id) return false;

    try {
      final result = await _authService.followUser(userId);
      
      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfollow(String userId) async {
    if (_currentUser == null || userId == _currentUser!.id) return false;

    try {
      final result = await _authService.unfollowUser(userId);
      
      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String bio,
    String? imagePath,
    String? city,
    String? country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        displayName,
        bio,
        imagePath: imagePath,
        city: city,
        country: country,
      );
      
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