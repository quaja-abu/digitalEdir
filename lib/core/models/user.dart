class User {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final String? profileImage;
  final bool isActive;
  final List<String>? groupIds;
  final Map<String, dynamic>? permissions;

  User({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.role = 'member',
    required this.createdAt,
    this.profileImage,
    this.isActive = true,
    this.groupIds,
    this.permissions,
  });

  User copyWith({
    bool? isActive,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: createdAt,
      profileImage: profileImage,
      isActive: isActive ?? this.isActive,
      groupIds: groupIds,
      permissions: permissions,
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      role: map['role'] ?? 'member',
      createdAt: DateTime.parse(map['createdAt']),
      profileImage: map['profileImage'] as String?,
      isActive: map['isActive'] ?? true,
      groupIds:
          map['groupIds'] != null ? List<String>.from(map['groupIds']) : null,
      permissions: map['permissions'] != null
          ? Map<String, dynamic>.from(map['permissions'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'profileImage': profileImage,
      'isActive': isActive,
      'groupIds': groupIds,
      'permissions': permissions,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'member',
      createdAt: DateTime.parse(json['createdAt']),
      profileImage: json['profileImage'],
      isActive: json['isActive'] ?? true,
      groupIds: List<String>.from(json['groupIds'] ?? []),
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
    );
  }
}
