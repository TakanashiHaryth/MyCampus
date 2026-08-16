import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'authenticated_shell.dart';
import 'app_theme.dart';
import 'core/app_dependencies.dart';
import 'core/theme_controller.dart';
import 'models/auth_session.dart';
import 'models/user_profile.dart';
import 'shared_widgets.dart';

class MyCampusApp extends StatefulWidget {
  const MyCampusApp({
    required this.dependencies,
    this.themeController,
    super.key,
  });

  final AppDependencies dependencies;
  final ThemeController? themeController;

  @override
  State<MyCampusApp> createState() => _MyCampusAppState();
}

class _MyCampusAppState extends State<MyCampusApp> {
  late final ThemeController _themeController;
  late final bool _ownsThemeController;

  @override
  void initState() {
    super.initState();
    _ownsThemeController = widget.themeController == null;
    _themeController = widget.themeController ?? ThemeController();
  }

  @override
  void dispose() {
    if (_ownsThemeController) _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) => MaterialApp(
        title: 'My Campus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeController.mode,
        home: _AuthGate(
          dependencies: widget.dependencies,
          themeController: _themeController,
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.dependencies, required this.themeController});

  final AppDependencies dependencies;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthSession?>(
      stream: dependencies.auth.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _GateLoading(message: 'Restoring your session…');
        }
        if (authSnapshot.hasError) {
          return const _GateError(
            title: 'Unable to restore your session',
            message: 'Check your connection and restart My Campus.',
          );
        }
        final session = authSnapshot.data;
        if (session == null) return AuthScreen(auth: dependencies.auth);

        return StreamBuilder<UserProfile?>(
          stream: dependencies.profiles.watchProfile(session.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _GateLoading(
                message: 'Loading your campus profile…',
              );
            }
            if (profileSnapshot.hasError) {
              return _GateError(
                title: 'Unable to load your profile',
                message: 'Check your connection and Firestore access.',
                onSignOut: dependencies.auth.signOut,
              );
            }
            final profile = profileSnapshot.data;
            if (profile == null) {
              return _GateError(
                title: 'Campus profile missing',
                message: 'This Firebase account does not have a My Campus profile yet.',
                onSignOut: dependencies.auth.signOut,
              );
            }
            return AuthenticatedShell(
              session: session,
              profile: profile,
              dependencies: dependencies,
              themeController: themeController,
            );
          },
        );
      },
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 48),
              const SizedBox(height: AppSpacing.lg),
              const LinearProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _GateError extends StatelessWidget {
  const _GateError({
    required this.title,
    required this.message,
    this.onSignOut,
  });

  final String title;
  final String message;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppErrorState(
            title: title,
            message: message,
            actionLabel: 'Sign out',
            actionIcon: Icons.logout_rounded,
            onRetry: onSignOut == null
                ? null
                : () async {
                    await onSignOut!();
                  },
          ),
        ),
      ),
    );
  }
}
