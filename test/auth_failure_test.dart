import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_campus/core/auth_service.dart';
import 'package:my_campus/core/errors/app_failure.dart';
import 'package:my_campus/core/user_profile_repository.dart';

void main() {
  group('Firebase Auth error mapping', () {
    test('recognizes the Windows configuration-not-found message', () {
      final failure = mapFirebaseAuthFailure(
        FirebaseAuthException(
          code: 'unknown-error',
          message: 'CONFIGURATION_NOT_FOUND',
        ),
      );

      expect(failure.code, 'configuration-not-found');
      expect(failure.message, contains('not configured'));
    });

    test('keeps duplicate email errors actionable', () {
      final failure = mapFirebaseAuthFailure(
        FirebaseAuthException(code: 'email-already-in-use'),
      );

      expect(failure.code, 'email-already-in-use');
      expect(failure.message, contains('already exists'));
    });
  });

  group('profile creation error mapping', () {
    test('keeps validation failures unchanged', () {
      const original = AppFailure(
        'That username is already in use.',
        code: 'username-taken',
      );

      expect(mapProfileCreationFailure(original), same(original));
    });

    test('identifies a disabled Firestore API', () {
      final failure = mapProfileCreationFailure(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Cloud Firestore API has not been used or is disabled.',
        ),
      );

      expect(failure.code, 'firestore-not-configured');
      expect(failure.message, contains('not configured'));
    });

    test('maps transient Firestore failures to a retryable message', () {
      final failure = mapProfileCreationFailure(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(failure.code, 'firestore-unavailable');
      expect(failure.message, contains('temporarily unavailable'));
    });
  });
}
