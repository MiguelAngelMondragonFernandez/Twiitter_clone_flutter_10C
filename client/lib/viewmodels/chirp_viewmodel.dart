import 'package:flutter/material.dart';
import '../models/chirp.dart';
import '../services/chirp_service.dart';

class ChirpViewModel extends ChangeNotifier {
  final ChirpService _chirpService = ChirpService();

  List<Chirp> _chirps = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 0;

  List<Chirp> get chirps => _chirps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load feed
  Future<void> loadFeed({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _chirps = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newChirps = await _chirpService.getFeed(page: _currentPage);

      if (newChirps.isEmpty) {
        _hasMore = false;
      } else {
        _chirps.addAll(newChirps);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create chirp
  Future<bool> createChirp(String content, {String? replyToId}) async {
    _error = null;
    notifyListeners();

    try {
      final newChirp = await _chirpService.createChirp(
        content,
        replyToId: replyToId,
      );
      _chirps.insert(0, newChirp);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete chirp
  Future<bool> deleteChirp(String chirpId) async {
    _error = null;
    notifyListeners();

    try {
      await _chirpService.deleteChirp(chirpId);
      _chirps.removeWhere((chirp) => chirp.id == chirpId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle like
  Future<void> toggleLike(String chirpId) async {
    final index = _chirps.indexWhere((chirp) => chirp.id == chirpId);
    if (index == -1) return;

    final chirp = _chirps[index];
    final wasLiked = chirp.isLiked;

    // Optimistic update
    _chirps[index] = chirp.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? chirp.likesCount - 1 : chirp.likesCount + 1,
    );
    notifyListeners();

    try {
      if (wasLiked) {
        await _chirpService.unlikeChirp(chirpId);
      } else {
        await _chirpService.likeChirp(chirpId);
      }
    } catch (e) {
      // Revert on error
      _chirps[index] = chirp;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Repost chirp
  Future<void> repostChirp(String chirpId) async {
    final index = _chirps.indexWhere((chirp) => chirp.id == chirpId);
    if (index == -1) return;

    final chirp = _chirps[index];
    if (chirp.isReposted) return; // Already reposted

    // Optimistic update
    _chirps[index] = chirp.copyWith(
      isReposted: true,
      repostsCount: chirp.repostsCount + 1,
    );
    notifyListeners();

    try {
      await _chirpService.repostChirp(chirpId);
    } catch (e) {
      // Revert on error
      _chirps[index] = chirp;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load user chirps
  Future<void> loadUserChirps(String userId) async {
    _isLoading = true;
    _error = null;
    _chirps = [];
    notifyListeners();

    try {
      _chirps = await _chirpService.getUserChirps(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
