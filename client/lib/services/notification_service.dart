import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class NotificationService {
  final AuthService _authService = AuthService();

  // Get notifications
  Future<List<Notification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.notifications}?page=$page&size=$size',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar notificaciones');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.unreadCount}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.markAsRead}/$notificationId',
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al marcar como leída');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.markAsRead}/all'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al marcar todas como leídas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId',
        ),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar notificación');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
