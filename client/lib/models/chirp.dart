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
  final User? repostedBy;
  final List<String> imageUrls;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;

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
    this.repostedBy,
    this.imageUrls = const [],
    this.latitude,
    this.longitude,
    this.city,
    this.country,
  });

  factory Chirp.fromJson(Map<String, dynamic> json) {
    return Chirp(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      createdAt: DateTime.parse(
        (json['createdAt']?.toString() ?? DateTime.now().toIso8601String()) +
            (json['createdAt']?.toString().endsWith('Z') == true ? '' : 'Z'),
      ).toLocal(),
      likesCount: json['likesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      repostsCount: json['repostsCount'] ?? 0,
      isLiked: json['liked'] ?? json['isLiked'] ?? false,
      isReposted: json['reposted'] ?? json['isReposted'] ?? false,
      replyToId: json['replyToId']?.toString(),
      repostedBy: json['repostedBy'] != null
          ? User.fromJson(json['repostedBy'])
          : null,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      country: json['country'],
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
      'repostedBy': repostedBy?.toJson(),
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
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
    User? repostedBy,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
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
      repostedBy: repostedBy ?? this.repostedBy,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}
