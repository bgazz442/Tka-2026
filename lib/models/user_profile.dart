import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String username;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'name': name,
        'email': email,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final resolvedName = (json['name'] as String?) ??
        (json['username'] as String?) ??
        (json['displayName'] as String?) ??
        '';
    final resolvedUsername = (json['username'] as String?) ?? resolvedName;
    final resolvedEmail = (json['email'] as String?) ?? '';

    return UserProfile(
      uid: json['uid'] as String? ?? '',
      username: resolvedUsername,
      name: resolvedName,
      email: resolvedEmail,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? username,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
