import 'user.dart';

class Chirp {
  final String id;
  final String content;
  final User author;
  final DateTime createdAt;
  final int likesCount;
  final int repliesCount;
  final int repostsCount;
  final bool isLiked;
  final bool isReposted;
  final String? replyToId;

  Chirp({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.repostsCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.replyToId,
  });

  factory Chirp.fromJson(Map<String, dynamic> json) {
    return Chirp(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      likesCount: json['likesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      repostsCount: json['repostsCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      replyToId: json['replyToId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'repostsCount': repostsCount,
      'isLiked': isLiked,
      'isReposted': isReposted,
      'replyToId': replyToId,
    };
  }

  Chirp copyWith({
    String? id,
    String? content,
    User? author,
    DateTime? createdAt,
    int? likesCount,
    int? repliesCount,
    int? repostsCount,
    bool? isLiked,
    bool? isReposted,
    String? replyToId,
  }) {
    return Chirp(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      replyToId: replyToId ?? this.replyToId,
    );
  }
}
