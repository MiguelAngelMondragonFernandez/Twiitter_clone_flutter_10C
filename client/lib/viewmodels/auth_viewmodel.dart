import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  firebase_auth.FirebaseAuth? _firebaseAuth;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthViewModel() {
    _initFirebaseAuth();
    checkAuthStatus(); // Check for stored session on init
  }

  void _initFirebaseAuth() {
    try {
      _firebaseAuth = firebase_auth.FirebaseAuth.instance;
      // Optional: Listen to Firebase auth state if needed for other features
      // _initAuthStateListener(); 
    } catch (e) {
      print('FirebaseAuth initialization failed: $e');
      // Non-blocking error, we can still use HTTP auth
    }
  }

  // 🔥 Escucha cambios en Firebase Auth (Optional)
  void _initAuthStateListener() {
    _firebaseAuth?.authStateChanges().listen((firebaseUser) {
      // This might conflict with HTTP auth if not careful, 
      // so we rely primarily on AuthService for state management now.
    });
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Check for stored user in SharedPreferences (via AuthService)
      final storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        _currentUser = storedUser;
        // Optionally verify token validity with backend here
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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Attempt HTTP Login
      final result = await _authService.login(email, password);

      if (result['success']) {
        _currentUser = result['user'];
        
        // 2. Optional: Attempt Firebase Login (for features that might need it)
        if (_firebaseAuth != null) {
          try {
            await _firebaseAuth!.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (e) {
            print('Firebase login failed (ignoring): $e');
          }
        }

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
      // 1. Attempt HTTP Register
      final result = await _authService.register(username, email, password);

      if (result['success']) {
        _currentUser = result['user'];

        // 2. Optional: Attempt Firebase Register
        if (_firebaseAuth != null) {
           try {
            await _firebaseAuth!.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
             await _firebaseAuth!.currentUser?.updateDisplayName(username);
          } catch (e) {
            print('Firebase register failed (ignoring): $e');
          }
        }

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
    try {
      // 1. HTTP Logout (Clear local storage)
      await _authService.logout();
      
      // 2. Firebase Logout
      if (_firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }

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
      if (result['success']) {
         _currentUser = _currentUser!.copyWith(
          followingCount: _currentUser!.followingCount + 1,
        );
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
      if (result['success']) {
        _currentUser = _currentUser!.copyWith(
          followingCount: _currentUser!.followingCount > 0 ? _currentUser!.followingCount - 1 : 0,
        );
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
      // 1. HTTP Update Profile
      final updatedUser = await _authService.updateProfile(
        displayName, 
        bio, 
        imagePath: imagePath,
        city: city,
        country: country
      );
      
      _currentUser = updatedUser;

      // 2. Optional: Firebase Update Profile
      if (_firebaseAuth != null) {
        try {
          await _firebaseAuth!.currentUser?.updateDisplayName(displayName);
        } catch (e) {
           print('Firebase profile update failed (ignoring): $e');
        }
      }
      
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