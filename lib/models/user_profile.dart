import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

class UserProfileDraft {
  const UserProfileDraft({
    required this.name,
    required this.username,
    required this.studentId,
    required this.className,
    required this.course,
  });

  final String name;
  final String username;
  final String studentId;
  final String className;
  final String course;
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.studentId,
    required this.studentEmail,
    required this.className,
    required this.course,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String username;
  final String studentId;
  final String studentEmail;
  final String className;
  final String course;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserProfile.fromMap(Map<String, Object?> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentEmail: map['studentEmail'] as String? ?? '',
      className: map['className'] as String? ?? '',
      course: map['course'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {
    'uid': uid,
    'name': name,
    'username': username,
    'studentId': studentId,
    'studentEmail': studentEmail,
    'className': className,
    'course': course,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };

  UserProfile copyWith({
    String? name,
    String? username,
    String? studentId,
    String? studentEmail,
    String? className,
    String? course,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      studentId: studentId ?? this.studentId,
      studentEmail: studentEmail ?? this.studentEmail,
      className: className ?? this.className,
      course: course ?? this.course,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PublicUserProfile {
  const PublicUserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.studentId,
    required this.className,
    required this.course,
    this.avatarUrl,
  });

  final String uid;
  final String name;
  final String username;
  final String studentId;
  final String className;
  final String course;
  final String? avatarUrl;

  factory PublicUserProfile.fromMap(Map<String, Object?> map) {
    return PublicUserProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      className: map['className'] as String? ?? '',
      course: map['course'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    'uid': uid,
    'name': name,
    'username': username,
    'studentId': studentId,
    'className': className,
    'course': course,
    'avatarUrl': avatarUrl,
  };

  PublicUserProfile copyWith({
    String? name,
    String? username,
    String? studentId,
    String? className,
    String? course,
    String? avatarUrl,
  }) {
    return PublicUserProfile(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      course: course ?? this.course,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
