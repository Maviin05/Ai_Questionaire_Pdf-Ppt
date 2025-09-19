class User {
  final String id;
  final String name;
  final String email;
  final String avatarPath;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> preferences;
  final List<String> favoriteSubjects;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath = '',
    required this.createdAt,
    required this.lastActiveAt,
    this.preferences = const {},
    this.favoriteSubjects = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarPath': avatarPath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActiveAt': lastActiveAt.millisecondsSinceEpoch,
      'preferences': preferences,
      'favoriteSubjects': favoriteSubjects,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarPath: json['avatarPath'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastActiveAt: DateTime.fromMillisecondsSinceEpoch(json['lastActiveAt']),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      favoriteSubjects: List<String>.from(json['favoriteSubjects'] ?? []),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    List<String>? favoriteSubjects,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      favoriteSubjects: favoriteSubjects ?? this.favoriteSubjects,
    );
  }
}
