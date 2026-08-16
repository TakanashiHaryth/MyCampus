import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_session.dart';
import '../models/user_profile.dart';
import 'errors/app_failure.dart';
import 'user_profile_repository.dart';

abstract interface class AuthService {
  Stream<AuthSession?> authStateChanges();
  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String email,
    required String password,
    required UserProfileDraft profile,
  });

  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth, this._profiles);

  final FirebaseAuth _auth;
  final UserProfileRepository _profiles;

  @override
  Stream<AuthSession?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthSession(uid: user.uid, email: user.email ?? '');
    });
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthFailure(error);
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required UserProfileDraft profile,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthFailure(error);
    }

    final user = credential.user;
    if (user == null) {
      throw const AppFailure(
        'Your account could not be created. Please try again.',
        code: 'missing-auth-user',
      );
    }

    try {
      await _profiles.createInitialProfile(
        uid: user.uid,
        email: email,
        draft: profile,
      );
    } catch (error) {
      final failure = mapProfileCreationFailure(error);
      try {
        await user.delete();
      } catch (_) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }
      throw failure;
    }

    // Firestore is the profile source of truth. Firebase displayName is a
    // convenience only, so a transient failure here must not roll back a
    // successfully-created account and profile.
    try {
      await user.updateDisplayName(profile.name.trim());
    } catch (_) {}
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthFailure(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthFailure(error);
    }
  }
}

AppFailure mapFirebaseAuthFailure(FirebaseAuthException error) {
  final normalizedMessage = error.message?.toUpperCase() ?? '';
  if (error.code == 'configuration-not-found' ||
      normalizedMessage.contains('CONFIGURATION_NOT_FOUND')) {
    return const AppFailure(
      'Account access is not configured yet. Please contact the My Campus administrator.',
      code: 'configuration-not-found',
    );
  }

  return switch (error.code) {
    'invalid-email' => const AppFailure(
      'Enter a valid email address.',
      code: 'invalid-email',
    ),
    'email-already-in-use' => const AppFailure(
      'An account already exists for this email.',
      code: 'email-already-in-use',
    ),
    'weak-password' => const AppFailure(
      'Use a stronger password with at least 8 characters.',
      code: 'weak-password',
    ),
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' => const AppFailure(
      'The email or password is incorrect.',
      code: 'invalid-credential',
    ),
    'too-many-requests' => const AppFailure(
      'Too many attempts. Please wait a moment and try again.',
      code: 'too-many-requests',
    ),
    'network-request-failed' => const AppFailure(
      'No connection. Check your internet and try again.',
      code: 'network-request-failed',
    ),
    'operation-not-allowed' => const AppFailure(
      'Email sign-in is not enabled for this Firebase project.',
      code: 'operation-not-allowed',
    ),
    'user-disabled' => const AppFailure(
      'This account has been disabled.',
      code: 'user-disabled',
    ),
    'invalid-api-key' || 'app-not-authorized' => const AppFailure(
      'This app is not authorized to use Firebase Authentication.',
      code: 'app-not-authorized',
    ),
    'quota-exceeded' => const AppFailure(
      'Account access is temporarily unavailable. Please try again later.',
      code: 'quota-exceeded',
    ),
    _ => const AppFailure(
      'We could not complete that request. Please try again.',
    ),
  };
}
