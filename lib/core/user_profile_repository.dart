import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import 'errors/app_failure.dart';

abstract interface class UserProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);
  Stream<PublicUserProfile?> watchPublicProfile(String uid);
  Future<PublicUserProfile?> getPublicProfile(String uid);

  Future<void> createInitialProfile({
    required String uid,
    required String email,
    required UserProfileDraft draft,
  });

  Future<void> updateProfile(UserProfile profile);
  Future<List<PublicUserProfile>> searchPublicProfiles(String query);
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('publicProfiles');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');
  CollectionReference<Map<String, dynamic>> get _studentIds =>
      _firestore.collection('studentIds');

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserProfile.fromMap(data);
    });
  }

  @override
  Stream<PublicUserProfile?> watchPublicProfile(String uid) {
    return _publicProfiles.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : PublicUserProfile.fromMap(data);
    });
  }

  @override
  Future<PublicUserProfile?> getPublicProfile(String uid) async {
    final snapshot = await _publicProfiles.doc(uid).get();
    final data = snapshot.data();
    return data == null ? null : PublicUserProfile.fromMap(data);
  }

  @override
  Future<void> createInitialProfile({
    required String uid,
    required String email,
    required UserProfileDraft draft,
  }) async {
    final usernameKey = _normalizeUsername(draft.username);
    final studentIdKey = _normalizeStudentId(draft.studentId);
    final usernameRef = _usernames.doc(usernameKey);
    final studentIdRef = _studentIds.doc(studentIdKey);
    final privateRef = _users.doc(uid);
    final publicRef = _publicProfiles.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final usernameSnapshot = await transaction.get(usernameRef);
      final studentIdSnapshot = await transaction.get(studentIdRef);
      final existingProfile = await transaction.get(privateRef);

      if (existingProfile.exists) {
        throw const AppFailure(
          'A campus profile already exists for this account.',
          code: 'profile-exists',
        );
      }
      if (usernameSnapshot.exists) {
        throw const AppFailure(
          'That username is already in use.',
          code: 'username-taken',
        );
      }
      if (studentIdSnapshot.exists) {
        throw const AppFailure(
          'That student ID is already registered.',
          code: 'student-id-taken',
        );
      }

      final privateData = <String, Object?>{
        'uid': uid,
        'name': draft.name.trim(),
        'username': draft.username.trim(),
        'usernameNormalized': usernameKey,
        'studentId': draft.studentId.trim().toUpperCase(),
        'studentIdNormalized': studentIdKey,
        'studentEmail': email.trim().toLowerCase(),
        'className': draft.className.trim(),
        'course': draft.course.trim(),
        'avatarUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final publicData = <String, Object?>{
        'uid': uid,
        'name': draft.name.trim(),
        'username': draft.username.trim(),
        'usernameNormalized': usernameKey,
        'studentId': draft.studentId.trim().toUpperCase(),
        'studentIdNormalized': studentIdKey,
        'className': draft.className.trim(),
        'course': draft.course.trim(),
        'avatarUrl': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(privateRef, privateData);
      transaction.set(publicRef, publicData);
      transaction.set(usernameRef, {
        'uid': uid,
        'value': usernameKey,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(studentIdRef, {
        'uid': uid,
        'value': studentIdKey,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final privateRef = _users.doc(profile.uid);
    final publicRef = _publicProfiles.doc(profile.uid);

    await _firestore.runTransaction((transaction) async {
      final currentSnapshot = await transaction.get(privateRef);
      final currentData = currentSnapshot.data();
      if (currentData == null) {
        throw const AppFailure(
          'Your profile could not be found.',
          code: 'profile-not-found',
        );
      }

      final oldUsername = currentData['usernameNormalized'] as String? ?? '';
      final oldStudentId = currentData['studentIdNormalized'] as String? ?? '';
      final newUsername = _normalizeUsername(profile.username);
      final newStudentId = _normalizeStudentId(profile.studentId);
      final newUsernameRef = _usernames.doc(newUsername);
      final newStudentIdRef = _studentIds.doc(newStudentId);

      if (newUsername != oldUsername) {
        final snapshot = await transaction.get(newUsernameRef);
        if (snapshot.exists) {
          throw const AppFailure(
            'That username is already in use.',
            code: 'username-taken',
          );
        }
      }
      if (newStudentId != oldStudentId) {
        final snapshot = await transaction.get(newStudentIdRef);
        if (snapshot.exists) {
          throw const AppFailure(
            'That student ID is already registered.',
            code: 'student-id-taken',
          );
        }
      }

      transaction.update(privateRef, {
        'name': profile.name.trim(),
        'username': profile.username.trim(),
        'usernameNormalized': newUsername,
        'studentId': profile.studentId.trim().toUpperCase(),
        'studentIdNormalized': newStudentId,
        'className': profile.className.trim(),
        'course': profile.course.trim(),
        'avatarUrl': profile.avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(publicRef, {
        'uid': profile.uid,
        'name': profile.name.trim(),
        'username': profile.username.trim(),
        'usernameNormalized': newUsername,
        'studentId': profile.studentId.trim().toUpperCase(),
        'studentIdNormalized': newStudentId,
        'className': profile.className.trim(),
        'course': profile.course.trim(),
        'avatarUrl': profile.avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (newUsername != oldUsername) {
        if (oldUsername.isNotEmpty) {
          transaction.delete(_usernames.doc(oldUsername));
        }
        transaction.set(newUsernameRef, {
          'uid': profile.uid,
          'value': newUsername,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (newStudentId != oldStudentId) {
        if (oldStudentId.isNotEmpty) {
          transaction.delete(_studentIds.doc(oldStudentId));
        }
        transaction.set(newStudentIdRef, {
          'uid': profile.uid,
          'value': newStudentId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<List<PublicUserProfile>> searchPublicProfiles(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];
    if (!_usernamePattern.hasMatch(trimmed) &&
        !_studentIdPattern.hasMatch(trimmed)) {
      return const [];
    }

    final lookupSnapshots = await Future.wait([
      _usernames.doc(trimmed.toLowerCase()).get(),
      _studentIds.doc(trimmed.toUpperCase()).get(),
    ]);
    final uids = lookupSnapshots
        .map((snapshot) => snapshot.data()?['uid'])
        .whereType<String>()
        .toSet();
    final profiles = await Future.wait(uids.map(getPublicProfile));
    return profiles.whereType<PublicUserProfile>().toList(growable: false);
  }

  static final _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{3,30}$');
  static final _studentIdPattern = RegExp(r'^[A-Za-z0-9-]{3,30}$');

  String _normalizeUsername(String value) {
    final trimmed = value.trim();
    if (!_usernamePattern.hasMatch(trimmed)) {
      throw const AppFailure(
        'Username may only use letters, numbers, dots, dashes and underscores.',
        code: 'invalid-username',
      );
    }
    return trimmed.toLowerCase();
  }

  String _normalizeStudentId(String value) {
    final trimmed = value.trim();
    if (!_studentIdPattern.hasMatch(trimmed)) {
      throw const AppFailure(
        'Student ID may only use letters, numbers and dashes.',
        code: 'invalid-student-id',
      );
    }
    return trimmed.toUpperCase();
  }
}

AppFailure mapProfileCreationFailure(Object error) {
  if (error is AppFailure) return error;
  if (error is! FirebaseException) {
    return const AppFailure(
      'Your campus profile could not be created. Please try again.',
      code: 'profile-create-failed',
    );
  }

  final normalizedMessage = error.message?.toUpperCase() ?? '';
  if (normalizedMessage.contains('FIRESTORE API') &&
      (normalizedMessage.contains('DISABLED') ||
          normalizedMessage.contains('HAS NOT BEEN USED'))) {
    return const AppFailure(
      'The My Campus database is not configured yet. Please contact the administrator.',
      code: 'firestore-not-configured',
    );
  }

  return switch (error.code) {
    'permission-denied' => const AppFailure(
      'Your campus profile could not be saved because database access was denied.',
      code: 'permission-denied',
    ),
    'not-found' || 'failed-precondition' => const AppFailure(
      'The My Campus database is not ready yet. Please contact the administrator.',
      code: 'firestore-not-configured',
    ),
    'unavailable' || 'deadline-exceeded' => const AppFailure(
      'The campus database is temporarily unavailable. Check your connection and try again.',
      code: 'firestore-unavailable',
    ),
    'unauthenticated' => const AppFailure(
      'Your account session expired. Please sign in and try again.',
      code: 'unauthenticated',
    ),
    'resource-exhausted' => const AppFailure(
      'The campus database is busy. Please wait a moment and try again.',
      code: 'resource-exhausted',
    ),
    _ => const AppFailure(
      'Your campus profile could not be created. Please try again.',
      code: 'profile-create-failed',
    ),
  };
}
