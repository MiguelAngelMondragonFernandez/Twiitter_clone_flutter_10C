import 'user.dart';
import 'chirp.dart';

enum NotificationType { like, repost, follow, reply, mention }

class Notification {
  final String id;
  final NotificationType type;
  final User actor; // Usuario que generó la notificación
  final Chirp? chirp; // Si es like/repost/reply, el chirp relacionado
  final String? content; // Para replies y mentions
  final DateTime createdAt;
  final bool isRead;

  Notification({
    required this.id,
    required this.type,
    required this.actor,
    this.chirp,
    this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String type) {
      switch (type.toLowerCase()) {
        case 'like':
          return NotificationType.like;
        case 'repost':
          return NotificationType.repost;
        case 'follow':
          return NotificationType.follow;
        case 'reply':
          return NotificationType.reply;
        case 'mention':
          return NotificationType.mention;
        default:
          return NotificationType.like;
      }
    }

    return Notification(
      id: json['id'] ?? '',
      type: parseType(json['type'] ?? 'like'),
      actor: User.fromJson(json['actor'] ?? {}),
      chirp: json['chirp'] != null ? Chirp.fromJson(json['chirp']) : null,
      content: json['content'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'actor': actor.toJson(),
      'chirp': chirp?.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  String get message {
    switch (type) {
      case NotificationType.like:
        return 'le gustó tu chirp';
      case NotificationType.repost:
        return 'reposteó tu chirp';
      case NotificationType.follow:
        return 'comenzó a seguirte';
      case NotificationType.reply:
        return 'respondió a tu chirp';
      case NotificationType.mention:
        return 'te mencionó en un chirp';
    }
  }

  Notification copyWith({
    String? id,
    NotificationType? type,
    User? actor,
    Chirp? chirp,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      actor: actor ?? this.actor,
      chirp: chirp ?? this.chirp,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
