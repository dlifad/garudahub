class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isVerified;
  final String? profilePhoto;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    this.profilePhoto,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isVerified: (json['is_verified'] ?? 0) == 1,
      profilePhoto: json['profile_photo'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'is_verified': isVerified,
        'profile_photo': profilePhoto,
      };
}