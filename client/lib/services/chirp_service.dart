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
      throw Exception('Error de conexión: $e');
    }
  }

  // Create chirp
  Future<Chirp> createChirp(String content, {String? replyToId}) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chirps}'),
        headers: headers,
        body: jsonEncode({
          'content': content,
          if (replyToId != null) 'replyToId': replyToId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Chirp.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear el chirp');
      }
    } catch (e) {
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
        throw Exception('Error al eliminar el chirp');
      }
    } catch (e) {
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
        throw Exception('Error al dar like');
      }
    } catch (e) {
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
      );

      if (response.statusCode != 200) {
        throw Exception('Error al quitar like');
      }
    } catch (e) {
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
        throw Exception('Error al cargar los chirps del usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
