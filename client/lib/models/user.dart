class User {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? bio;
  final String? profileImageUrl;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;
  final bool isFollowing;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.bio,
    this.profileImageUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.createdAt,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Backend expects Long, but we send String. Usually Jackson handles "123" -> 123.
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': createdAt.toIso8601String(),
      'isFollowing': isFollowing,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
