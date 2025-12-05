import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthViewModel() {
    _initAuthStateListener();
  }

  // 🔥 Escucha cambios en Firebase Auth
  void _initAuthStateListener() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _currentUser = _convertFirebaseUserToUser(firebaseUser);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // Convierte FirebaseUser a tu modelo User
  User _convertFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      username: firebaseUser.displayName ?? 'Usuario',
      email: firebaseUser.email ?? '',
      bio: '',
      profileImageUrl: firebaseUser.photoURL,
      followersCount: 0,
      followingCount: 0,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        _currentUser = _convertFirebaseUserToUser(firebaseUser);
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
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _currentUser = _convertFirebaseUserToUser(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
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
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);
        _currentUser = _convertFirebaseUserToUser(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
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
      await _authService.followUser(userId);
      _currentUser = _currentUser!.copyWith(
        followingCount: _currentUser!.followingCount + 1,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfollow(String userId) async {
    if (_currentUser == null || userId == _currentUser!.id) return false;

    try {
      await _authService.unfollowUser(userId);
      _currentUser = _currentUser!.copyWith(
        followingCount: _currentUser!.followingCount > 0 ? _currentUser!.followingCount - 1 : 0,
      );
      notifyListeners();
      return true;
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
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      
      _currentUser = _convertFirebaseUserToUser(_firebaseAuth.currentUser!).copyWith(
        bio: bio,
      );
      
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

  // Helper para convertir errores de Firebase a mensajes en español
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Error de autenticación';
    }
  }
}