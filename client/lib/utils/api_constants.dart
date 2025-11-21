class ApiConstants {
  // Cambia esta URL según tu backend
  static const String baseUrl = 'http://localhost:8081/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String users = '/users';
  static const String profile = '/users/profile';
  static const String follow = '/users/follow';
  static const String unfollow = '/users/unfollow';

  // Chirp endpoints
  static const String chirps = '/chirps';
  static const String feed = '/chirps/feed';
  static const String like = '/chirps/like';
  static const String unlike = '/chirps/unlike';
  static const String repost = '/chirps/repost';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read';
  static const String unreadCount = '/notifications/unread-count';

  // Search endpoints
  static const String search = '/search';
  static const String searchUsers = '/search/users';
  static const String searchChirps = '/search/chirps';
}
