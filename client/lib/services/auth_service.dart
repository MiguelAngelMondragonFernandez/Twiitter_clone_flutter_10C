import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';
import 'firebase_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        await _saveUser(data['user']);
        
        // Register FCM token
        await _registerFcmToken();
        
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        await _saveUser(data['user']);
        
        // Register FCM token
        await _registerFcmToken();
        
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Error al registrarse',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Follow a user
  Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/follow/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(userData),
        };
      } else {
        // Try to extract error message from response
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'error': errorData['message'] ?? 'Error al seguir usuario'};
        } catch (e) {
          return {'success': false, 'error': 'Error al seguir usuario (${response.statusCode})'};
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Unfollow a user
  Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/unfollow/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(userData),
        };
      } else {
        // Try to extract error message from response
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'error': errorData['message'] ?? 'Error al dejar de seguir'};
        } catch (e) {
          return {'success': false, 'error': 'Error al dejar de seguir (${response.statusCode})'};
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Private methods
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Get auth headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  // Update profile
  Future<User> updateProfile(String displayName, String bio, {String? imagePath, String? city, String? country}) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
      final request = http.MultipartRequest('PUT', uri);

      request.headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['displayName'] = displayName;
      request.fields['bio'] = bio;
      if (city != null) request.fields['city'] = city;
      if (country != null) request.fields['country'] = country;

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUser(data); 
        return User.fromJson(data);
      } else {
        print('Error updating profile: ${response.statusCode} ${response.body}');
        throw Exception('Error al actualizar perfil');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  // Fetch user profile from backend
  Future<User?> fetchUserProfile() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUser(data);
        return User.fromJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expired or invalid
        await logout();
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
  
  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final headers = await getAuthHeaders();
      final url = '${ApiConstants.baseUrl}/users/$userId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  // Register FCM token with backend
  Future<void> _registerFcmToken() async {
    try {
      final firebaseService = FirebaseService();
      final fcmToken = firebaseService.fcmToken;
      
      if (fcmToken == null) {
        print('No FCM token available');
        return;
      }
      
      print('Registering FCM token: ${fcmToken.substring(0, 20)}...');
      
      final headers = await getAuthHeaders();
      final url = '${ApiConstants.baseUrl}/notifications/register-token';
      print('Sending token to: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      
      if (response.statusCode == 200) {
        print('FCM token registered successfully');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }
}
