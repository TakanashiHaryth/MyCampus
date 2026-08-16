import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_campus/app.dart';
import 'package:my_campus/app_theme.dart';
import 'package:my_campus/core/app_dependencies.dart';
import 'package:my_campus/core/auth_service.dart';
import 'package:my_campus/core/dashboard_repository.dart';
import 'package:my_campus/core/friendship_repository.dart';
import 'package:my_campus/core/theme_controller.dart';
import 'package:my_campus/core/user_profile_repository.dart';
import 'package:my_campus/models/auth_session.dart';
import 'package:my_campus/models/dashboard_models.dart';
import 'package:my_campus/models/friendship.dart';
import 'package:my_campus/models/user_profile.dart';

class FakeAuthService implements AuthService {
  FakeAuthService([this._session]);

  AuthSession? _session;
  final _changes = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield _session;
    yield* _changes.stream;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required UserProfileDraft profile,
  }) async {
    _session = AuthSession(uid: 'uid-a', email: email);
    _changes.add(_session);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signIn({required String email, required String password}) async {
    _session = AuthSession(uid: 'uid-a', email: email);
    _changes.add(_session);
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}

class FakeProfiles implements UserProfileRepository {
  FakeProfiles(this.profile);

  UserProfile? profile;

  @override
  Future<void> createInitialProfile({
    required String uid,
    required String email,
    required UserProfileDraft draft,
  }) async {}

  @override
  Future<PublicUserProfile?> getPublicProfile(String uid) async => null;

  @override
  Future<List<PublicUserProfile>> searchPublicProfiles(String query) async =>
      const [];

  @override
  Future<void> updateProfile(UserProfile profile) async {
    this.profile = profile;
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(profile);

  @override
  Stream<PublicUserProfile?> watchPublicProfile(String uid) =>
      Stream.value(null);
}

class FakeFriendships implements FriendshipRepository {
  @override
  Future<void> removeFriend({
    required String friendshipId,
    required String currentUid,
  }) async {}

  @override
  Future<void> respondToRequest({
    required String friendshipId,
    required String currentUid,
    required bool accept,
  }) async {}

  @override
  Future<void> sendRequest({
    required String currentUid,
    required String targetUid,
  }) async {}

  @override
  Stream<List<Friendship>> watchAccepted(String currentUid) =>
      Stream.value(const []);

  @override
  Stream<List<Friendship>> watchIncomingRequests(String currentUid) =>
      Stream.value(const []);

  @override
  Stream<List<Friendship>> watchOutgoingRequests(String currentUid) =>
      Stream.value(const []);
}

class FakeDashboard implements DashboardRepository {
  @override
  Stream<List<DashboardNotice>> watchRecentNotices(String uid) =>
      Stream.value(const []);

  @override
  Stream<List<DashboardSchedule>> watchTodaySchedules(String uid) =>
      Stream.value(const []);
}

const testProfile = UserProfile(
  uid: 'uid-a',
  name: 'Haryth Student',
  username: 'haryth',
  studentId: 'MMR2006',
  studentEmail: 'student@example.com',
  className: 'DMM',
  course: 'Diploma Multimedia',
);

AppDependencies dependenciesFor({bool signedIn = false}) {
  return AppDependencies(
    auth: FakeAuthService(
      signedIn
          ? const AuthSession(uid: 'uid-a', email: 'student@example.com')
          : null,
    ),
    profiles: FakeProfiles(testProfile),
    friendships: FakeFriendships(),
    dashboard: FakeDashboard(),
  );
}

Future<void> pumpStreams(WidgetTester tester) async {
  for (var index = 0; index < 6; index++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('signed-out users see Firebase email login and validation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MyCampusApp(dependencies: dependenciesFor()));
    await pumpStreams(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed-in users land on the realtime dashboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MyCampusApp(dependencies: dependenciesFor(signedIn: true)),
    );
    await pumpStreams(tester);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.endsWith(', Haryth') ?? false),
      ),
      findsOneWidget,
    );
    expect(find.text("Today's schedule"), findsOneWidget);
    expect(find.text('Nothing scheduled for today'), findsOneWidget);
    expect(find.text('MY CAMPUS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive shell has no overflow at required PRD sizes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final dependencies = dependenciesFor(signedIn: true);

    for (final size in const [
      Size(360, 800),
      Size(412, 915),
      Size(768, 1024),
      Size(1366, 768),
      Size(1920, 1080),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(MyCampusApp(dependencies: dependencies));
      await pumpStreams(tester);
      expect(tester.takeException(), isNull, reason: 'Overflow at $size');
    }
  });

  testWidgets('desktop sidebar navigates to the scalable friends page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1366, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MyCampusApp(dependencies: dependenciesFor(signedIn: true)),
    );
    await pumpStreams(tester);

    await tester.tap(find.text('Friends').first);
    await pumpStreams(tester);
    expect(find.text('Add a friend'), findsOneWidget);
    expect(find.text('No friends yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme controller supports light, dark and system modes', (
    tester,
  ) async {
    final controller = ThemeController(initialMode: ThemeMode.light);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MyCampusApp(dependencies: dependenciesFor(), themeController: controller),
    );
    await pumpStreams(tester);

    var context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).colorScheme.primary, AppColors.primary);

    controller.setMode(ThemeMode.dark);
    await pumpStreams(tester);
    context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);

    controller.setMode(ThemeMode.system);
    expect(controller.mode, ThemeMode.system);
  });
}
