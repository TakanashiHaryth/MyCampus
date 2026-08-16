import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'dashboard_repository.dart';
import 'friendship_repository.dart';
import 'user_profile_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.auth,
    required this.profiles,
    required this.friendships,
    required this.dashboard,
  });

  factory AppDependencies.firebase() {
    final firestore = FirebaseFirestore.instance;
    final profiles = FirestoreUserProfileRepository(firestore);
    return AppDependencies(
      auth: FirebaseAuthService(FirebaseAuth.instance, profiles),
      profiles: profiles,
      friendships: FirestoreFriendshipRepository(firestore),
      dashboard: FirestoreDashboardRepository(firestore),
    );
  }

  final AuthService auth;
  final UserProfileRepository profiles;
  final FriendshipRepository friendships;
  final DashboardRepository dashboard;
}
