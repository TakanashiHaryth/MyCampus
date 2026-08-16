import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'app_theme.dart';
import 'core/app_dependencies.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _FirebaseBootstrapApp());
}

class _FirebaseBootstrapApp extends StatefulWidget {
  const _FirebaseBootstrapApp();

  @override
  State<_FirebaseBootstrapApp> createState() => _FirebaseBootstrapAppState();
}

class _FirebaseBootstrapAppState extends State<_FirebaseBootstrapApp> {
  AppDependencies? _dependencies;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (_failed && mounted) setState(() => _failed = false);
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      if (mounted) {
        setState(() => _dependencies = AppDependencies.firebase());
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = _dependencies;
    if (dependencies != null) return MyCampusApp(dependencies: dependencies);

    final title = _failed ? 'Firebase could not start' : 'Starting My Campus';
    final message = _failed
        ? 'Check your Firebase configuration and internet connection. No private configuration details are shown here.'
        : 'Preparing your secure campus workspace…';

    return MaterialApp(
      title: 'My Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _failed ? Icons.cloud_off_outlined : Icons.school_rounded,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  if (_failed)
                    ElevatedButton.icon(
                      onPressed: _initialize,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    )
                  else
                    Semantics(
                      liveRegion: true,
                      label: 'Starting My Campus',
                      child: const LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
