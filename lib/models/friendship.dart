import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendshipStatus {
  pending,
  accepted,
  rejected,
  blocked;

  static FriendshipStatus fromValue(Object? value) {
    return FriendshipStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => FriendshipStatus.pending,
    );
  }
}

class Friendship {
  const Friendship({
    required this.id,
    required this.users,
    required this.status,
    required this.requestedBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final List<String> users;
  final FriendshipStatus status;
  final String requestedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Friendship.fromMap(String id, Map<String, Object?> map) {
    DateTime? readDate(Object? value) => value is Timestamp
        ? value.toDate()
        : value is DateTime
        ? value
        : null;

    return Friendship(
      id: id,
      users: List<String>.unmodifiable(
        (map['users'] as List<Object?>? ?? const []).whereType<String>(),
      ),
      status: FriendshipStatus.fromValue(map['status']),
      requestedBy: map['requestedBy'] as String? ?? '',
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {
    'users': users,
    'status': status.name,
    'requestedBy': requestedBy,
    'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };

  String otherUserId(String currentUid) {
    return users.firstWhere((uid) => uid != currentUid, orElse: () => '');
  }

  bool isIncomingFor(String currentUid) {
    return status == FriendshipStatus.pending && requestedBy != currentUid;
  }

  Friendship copyWith({
    List<String>? users,
    FriendshipStatus? status,
    String? requestedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Friendship(
      id: id,
      users: users ?? this.users,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String canonicalFriendshipId(String firstUid, String secondUid) {
  if (firstUid.isEmpty || secondUid.isEmpty) {
    throw ArgumentError('Friendship UIDs cannot be empty.');
  }
  if (firstUid == secondUid) {
    throw ArgumentError('A user cannot befriend their own account.');
  }
  final sorted = [firstUid, secondUid]..sort();
  return '${sorted.first}_${sorted.last}';
}
