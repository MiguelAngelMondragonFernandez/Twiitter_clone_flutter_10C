import 'package:flutter/material.dart';
import '../models/chirp.dart';
import '../services/chirp_service.dart';
import '../services/location_service.dart';

class ChirpViewModel extends ChangeNotifier {
  final ChirpService _chirpService = ChirpService();
  final LocationService _locationService = LocationService();

  // State for Home Feed
  List<Chirp> _feedChirps = [];
  bool _isFeedLoading = false;
  String? _feedError;
  bool _feedHasMore = true;
  int _feedCurrentPage = 0;

  List<Chirp> get feedChirps => _feedChirps;
  bool get isFeedLoading => _isFeedLoading;
  String? get feedError => _feedError;
  bool get feedHasMore => _feedHasMore;

  // State for User Profile
  List<Chirp> _userProfileChirps = [];
  bool _isUserProfileLoading = false;
  String? _userProfileError;

  List<Chirp> get userProfileChirps => _userProfileChirps;
  bool get isUserProfileLoading => _isUserProfileLoading;
  String? get userProfileError => _userProfileError;

  // General error state
  String? _error;
  String? get error => _error;

  // Load feed
  Future<void> loadFeed({bool refresh = false}) async {
    if (_isFeedLoading) return;

    if (refresh) {
      _feedCurrentPage = 0;
      _feedChirps = [];
      _feedHasMore = true;
    }

    _isFeedLoading = true;
    _feedError = null;
    notifyListeners();

    try {
      final newChirps = await _chirpService.getFeed(page: _feedCurrentPage);

      if (newChirps.length < 20) {
        _feedHasMore = false;
      }

      if (newChirps.isNotEmpty) {
        _feedChirps.addAll(newChirps);
        _feedCurrentPage++;
      }
    } catch (e) {
      _feedError = e.toString();
    }

    _isFeedLoading = false;
    notifyListeners();
  }

  // Create chirp - adds to the feed
  Future<bool> createChirp(String content, {String? replyToId, List<String>? imagePaths}) async {
    _error = null;
    notifyListeners();
    
    try {
      // Get current location
      Map<String, dynamic>? locationData = await _locationService.getCurrentLocation();
      
      final newChirp = await _chirpService.createChirp(
        content,
        replyToId: replyToId,
        imagePaths: imagePaths,
        latitude: locationData?['latitude'],
        longitude: locationData?['longitude'],
        city: locationData?['city'],
        country: locationData?['country'],
      );
      _feedChirps.insert(0, newChirp);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete chirp - removes from both lists
  Future<bool> deleteChirp(String chirpId) async {
    try {
      await _chirpService.deleteChirp(chirpId);
      _feedChirps.removeWhere((chirp) => chirp.id == chirpId);
      _userProfileChirps.removeWhere((chirp) => chirp.id == chirpId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle like - updates in both lists to maintain consistency
  Future<String?> toggleLike(String chirpId) async {
    final feedIndex = _feedChirps.indexWhere((c) => c.id == chirpId);
    final profileIndex = _userProfileChirps.indexWhere((c) => c.id == chirpId);

    if (feedIndex == -1 && profileIndex == -1) return null;

    Chirp? originalFeedChirp;
    Chirp? originalProfileChirp;

    final wasLiked = (feedIndex != -1 ? _feedChirps[feedIndex].isLiked : _userProfileChirps[profileIndex].isLiked);

    // Optimistic update
    if (feedIndex != -1) {
      originalFeedChirp = _feedChirps[feedIndex];
      _feedChirps[feedIndex] = originalFeedChirp.copyWith(
        isLiked: !wasLiked,
        likesCount: wasLiked ? originalFeedChirp.likesCount - 1 : originalFeedChirp.likesCount + 1,
      );
    }
    if (profileIndex != -1) {
      originalProfileChirp = _userProfileChirps[profileIndex];
      _userProfileChirps[profileIndex] = originalProfileChirp.copyWith(
        isLiked: !wasLiked,
        likesCount: wasLiked ? originalProfileChirp.likesCount - 1 : originalProfileChirp.likesCount + 1,
      );
    }
    notifyListeners();

    try {
      if (wasLiked) {
        await _chirpService.unlikeChirp(chirpId);
      } else {
        await _chirpService.likeChirp(chirpId);
      }
      return null;
    } catch (e) {
      // Revert on error
      if (feedIndex != -1 && originalFeedChirp != null) {
        _feedChirps[feedIndex] = originalFeedChirp;
      }
      if (profileIndex != -1 && originalProfileChirp != null) {
        _userProfileChirps[profileIndex] = originalProfileChirp;
      }
      notifyListeners();
      return e.toString();
    }
  }

  // Repost chirp - updates in both lists
  Future<void> repostChirp(String chirpId) async {
     final feedIndex = _feedChirps.indexWhere((c) => c.id == chirpId);
    final profileIndex = _userProfileChirps.indexWhere((c) => c.id == chirpId);

    if (feedIndex == -1 && profileIndex == -1) return;

    Chirp? originalFeedChirp;
    Chirp? originalProfileChirp;
    
    final wasReposted = (feedIndex != -1 ? _feedChirps[feedIndex].isReposted : _userProfileChirps[profileIndex].isReposted);

    // Optimistic update
    if (feedIndex != -1) {
      originalFeedChirp = _feedChirps[feedIndex];
      _feedChirps[feedIndex] = originalFeedChirp.copyWith(
        isReposted: !wasReposted,
        repostsCount: wasReposted ? originalFeedChirp.repostsCount - 1 : originalFeedChirp.repostsCount + 1,
      );
    }
     if (profileIndex != -1) {
      originalProfileChirp = _userProfileChirps[profileIndex];
      _userProfileChirps[profileIndex] = originalProfileChirp.copyWith(
        isReposted: !wasReposted,
        repostsCount: wasReposted ? originalProfileChirp.repostsCount - 1 : originalProfileChirp.repostsCount + 1,
      );
    }
    notifyListeners();

    try {
      if (wasReposted) {
        await _chirpService.unrepostChirp(chirpId);
      } else {
        await _chirpService.repostChirp(chirpId);
      }
    } catch (e) {
      // Revert on error
      if (feedIndex != -1 && originalFeedChirp != null) {
        _feedChirps[feedIndex] = originalFeedChirp;
      }
       if (profileIndex != -1 && originalProfileChirp != null) {
        _userProfileChirps[profileIndex] = originalProfileChirp;
      }
      notifyListeners();
    }
  }

  // Load user chirps
  Future<void> loadUserChirps(String userId) async {
    _isUserProfileLoading = true;
    _userProfileError = null;
    _userProfileChirps = []; // Only modify the profile list
    notifyListeners();

    try {
      _userProfileChirps = await _chirpService.getUserChirps(userId);
    } catch (e) {
      _userProfileError = e.toString();
    }

    _isUserProfileLoading = false;
    notifyListeners();
  }

  void clearError() {
    _feedError = null;
    _userProfileError = null;
    _error = null;
    notifyListeners();
  }
}
