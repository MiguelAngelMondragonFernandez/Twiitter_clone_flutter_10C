import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chirp.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class ChirpService {
  final AuthService _authService = AuthService();

  // Get feed
  Future<List<Chirp>> getFeed({int page = 0, int size = 20}) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.feed}?page=$page&size=$size',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Chirp.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar el feed');
      }
    } catch (e) {
      print('Error in getFeed: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Create chirp
  Future<Chirp> createChirp(
    String content, {
    String? replyToId,
    List<String>? imagePaths,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No token found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chirps}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;
      if (replyToId != null) {
        request.fields['replyToId'] = replyToId;
      }
      
      // Add geolocation data if provided
      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }
      if (city != null) {
        request.fields['city'] = city;
      }
      if (country != null) {
        request.fields['country'] = country;
      }

      if (imagePaths != null) {
        for (var path in imagePaths) {
          request.files.add(await http.MultipartFile.fromPath('images', path));
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Chirp.fromJson(jsonDecode(response.body));
      } else {
        print('Error creating chirp: ${response.statusCode} ${response.body}');
        throw Exception('Error al crear el chirp');
      }
    } catch (e) {
      print('Error in createChirp: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Delete chirp
  Future<void> deleteChirp(String chirpId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chirps}/$chirpId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Error deleting chirp: ${response.statusCode} ${response.body}');
        throw Exception('Error al eliminar el chirp');
      }
    } catch (e) {
      print('Error in deleteChirp: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Like chirp
  Future<void> likeChirp(String chirpId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.like}/$chirpId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Error liking chirp: ${response.statusCode} ${response.body}');
        throw Exception('Error al dar like');
      }
    } catch (e) {
      print('Error in likeChirp: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Unlike chirp
  Future<void> unlikeChirp(String chirpId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.unlike}/$chirpId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('Error unliking chirp: ${response.statusCode} ${response.body}');
        throw Exception('Error al quitar like');
      }
    } catch (e) {
      print('Error in unlikeChirp: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Repost chirp
  Future<void> repostChirp(String chirpId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.repost}/$chirpId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Error reposting chirp: ${response.statusCode} ${response.body}');
        throw Exception('Error al repostear');
      }
    } catch (e) {
      print('Error in repostChirp: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Unrepost chirp
  Future<void> unrepostChirp(String chirpId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.repost}/$chirpId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Error unreposting chirp: ${response.statusCode} ${response.body}');
        throw Exception('Error al eliminar repost');
      }
    } catch (e) {
      print('Error in unrepostChirp: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Get user chirps
  Future<List<Chirp>> getUserChirps(String userId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/chirps',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Chirp.fromJson(json)).toList();
      } else {
        print('Error getting user chirps: ${response.statusCode} ${response.body}');
        throw Exception('Error al cargar los chirps del usuario');
      }
    } catch (e) {
      print('Error in getUserChirps: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Get replies
  Future<List<Chirp>> getReplies(String chirpId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chirps}/$chirpId/replies'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Chirp.fromJson(json)).toList();
      } else {
        print('Error getting replies: ${response.statusCode} ${response.body}');
        throw Exception('Error al cargar las respuestas');
      }
    } catch (e) {
      print('Error in getReplies: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
