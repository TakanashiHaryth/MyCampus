import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_campus/models/friendship.dart';
import 'package:my_campus/models/user_profile.dart';

void main() {
  group('friendship architecture', () {
    test('canonical ID is identical for A to B and B to A', () {
      expect(canonicalFriendshipId('uid-z', 'uid-a'), 'uid-a_uid-z');
      expect(canonicalFriendshipId('uid-a', 'uid-z'), 'uid-a_uid-z');
    });

    test('self friendships and empty UIDs are rejected', () {
      expect(
        () => canonicalFriendshipId('uid-a', 'uid-a'),
        throwsArgumentError,
      );
      expect(() => canonicalFriendshipId('', 'uid-b'), throwsArgumentError);
    });

    test('typed friendship parses status, users and timestamps', () {
      final now = DateTime(2026, 8, 15, 10);
      final friendship = Friendship.fromMap('uid-a_uid-b', {
        'users': ['uid-a', 'uid-b'],
        'status': 'accepted',
        'requestedBy': 'uid-a',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      expect(friendship.status, FriendshipStatus.accepted);
      expect(friendship.otherUserId('uid-a'), 'uid-b');
      expect(friendship.createdAt, now);
      expect(friendship.isIncomingFor('uid-b'), isFalse);
    });
  });

  group('user profile model', () {
    test('handles Firestore timestamps and creates initials', () {
      final profile = UserProfile.fromMap({
        'uid': 'uid-a',
        'name': 'Haryth Student',
        'username': 'haryth',
        'studentId': 'MMR2006',
        'studentEmail': 'student@example.com',
        'className': 'DMM',
        'course': 'Diploma Multimedia',
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 15)),
      });

      expect(profile.initials, 'HS');
      expect(profile.createdAt, DateTime(2026, 8, 15));
      expect(profile.copyWith(className: 'DMM 4').className, 'DMM 4');
    });

    test('public profile mapping excludes private email fields', () {
      const profile = PublicUserProfile(
        uid: 'uid-a',
        name: 'Haryth Student',
        username: 'haryth',
        studentId: 'MMR2006',
        className: 'DMM',
        course: 'Diploma Multimedia',
      );

      expect(profile.toMap().containsKey('studentEmail'), isFalse);
      expect(profile.toMap()['uid'], 'uid-a');
    });
  });
}
