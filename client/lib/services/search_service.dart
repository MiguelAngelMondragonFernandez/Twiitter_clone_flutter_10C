import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/chirp.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class SearchService {
  final AuthService _authService = AuthService();

  // Search users
  Future<List<User>> searchUsers(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.searchUsers}?q=$query&page=$page&size=$size',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar usuarios');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Search chirps
  Future<List<Chirp>> searchChirps(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.searchChirps}?q=$query&page=$page&size=$size',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Chirp.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar chirps');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Search both users and chirps
  Future<Map<String, dynamic>> searchAll(String query) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.search}?q=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'users':
              (data['users'] as List<dynamic>?)
                  ?.map((json) => User.fromJson(json))
                  .toList() ??
              [],
          'chirps':
              (data['chirps'] as List<dynamic>?)
                  ?.map((json) => Chirp.fromJson(json))
                  .toList() ??
              [],
        };
      } else {
        throw Exception('Error en búsqueda');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
