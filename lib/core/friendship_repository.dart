import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/friendship.dart';
import 'errors/app_failure.dart';

abstract interface class FriendshipRepository {
  Stream<List<Friendship>> watchAccepted(String currentUid);
  Stream<List<Friendship>> watchIncomingRequests(String currentUid);
  Stream<List<Friendship>> watchOutgoingRequests(String currentUid);

  Future<void> sendRequest({
    required String currentUid,
    required String targetUid,
  });

  Future<void> respondToRequest({
    required String friendshipId,
    required String currentUid,
    required bool accept,
  });

  Future<void> removeFriend({
    required String friendshipId,
    required String currentUid,
  });
}

class FirestoreFriendshipRepository implements FriendshipRepository {
  FirestoreFriendshipRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _friendships =>
      _firestore.collection('friendships');

  Stream<List<Friendship>> _watch(String uid, FriendshipStatus status) {
    return _friendships
        .where('users', arrayContains: uid)
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
          final relationships = snapshot.docs
              .map(
                (document) => Friendship.fromMap(document.id, document.data()),
              )
              .toList(growable: false);
          relationships.sort((left, right) {
            final leftDate = left.updatedAt ?? left.createdAt;
            final rightDate = right.updatedAt ?? right.createdAt;
            if (leftDate == null && rightDate == null) return 0;
            if (leftDate == null) return 1;
            if (rightDate == null) return -1;
            return rightDate.compareTo(leftDate);
          });
          return relationships;
        });
  }

  @override
  Stream<List<Friendship>> watchAccepted(String currentUid) {
    return _watch(currentUid, FriendshipStatus.accepted);
  }

  @override
  Stream<List<Friendship>> watchIncomingRequests(String currentUid) {
    return _watch(currentUid, FriendshipStatus.pending).map(
      (items) => items
          .where((item) => item.isIncomingFor(currentUid))
          .toList(growable: false),
    );
  }

  @override
  Stream<List<Friendship>> watchOutgoingRequests(String currentUid) {
    return _watch(currentUid, FriendshipStatus.pending).map(
      (items) => items
          .where((item) => item.requestedBy == currentUid)
          .toList(growable: false),
    );
  }

  @override
  Future<void> sendRequest({
    required String currentUid,
    required String targetUid,
  }) async {
    final friendshipId = canonicalFriendshipId(currentUid, targetUid);
    final reference = _friendships.doc(friendshipId);
    final users = [currentUid, targetUid]..sort();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (data != null) {
        final existing = Friendship.fromMap(snapshot.id, data);
        switch (existing.status) {
          case FriendshipStatus.accepted:
            throw const AppFailure(
              'You are already friends with this student.',
              code: 'already-friends',
            );
          case FriendshipStatus.pending:
            throw AppFailure(
              existing.requestedBy == currentUid
                  ? 'A friend request is already pending.'
                  : 'This student has already sent you a friend request.',
              code: 'request-pending',
            );
          case FriendshipStatus.blocked:
            throw const AppFailure(
              'This friend request cannot be sent.',
              code: 'relationship-blocked',
            );
          case FriendshipStatus.rejected:
            transaction.update(reference, {
              'status': FriendshipStatus.pending.name,
              'requestedBy': currentUid,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return;
        }
      }

      transaction.set(reference, {
        'users': users,
        'status': FriendshipStatus.pending.name,
        'requestedBy': currentUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> respondToRequest({
    required String friendshipId,
    required String currentUid,
    required bool accept,
  }) async {
    final reference = _friendships.doc(friendshipId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (data == null) {
        throw const AppFailure(
          'This friend request no longer exists.',
          code: 'request-not-found',
        );
      }
      final friendship = Friendship.fromMap(snapshot.id, data);
      if (!friendship.users.contains(currentUid) ||
          friendship.requestedBy == currentUid ||
          friendship.status != FriendshipStatus.pending) {
        throw const AppFailure(
          'You cannot respond to this friend request.',
          code: 'invalid-friend-response',
        );
      }
      transaction.update(reference, {
        'status': accept
            ? FriendshipStatus.accepted.name
            : FriendshipStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> removeFriend({
    required String friendshipId,
    required String currentUid,
  }) async {
    final reference = _friendships.doc(friendshipId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (data == null) return;
      final friendship = Friendship.fromMap(snapshot.id, data);
      if (!friendship.users.contains(currentUid) ||
          friendship.status != FriendshipStatus.accepted) {
        throw const AppFailure(
          'You cannot remove this friendship.',
          code: 'invalid-friend-removal',
        );
      }
      transaction.delete(reference);
    });
  }
}
