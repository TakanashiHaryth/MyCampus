import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/theme_controller.dart';
import 'shared_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Settings',
                subtitle: 'Personalize how My Campus looks on this device.',
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Choose a theme or follow your system setting.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RadioGroup<ThemeMode>(
                      groupValue: themeController.mode,
                      onChanged: (value) {
                        if (value != null) themeController.setMode(value);
                      },
                      child: Column(
                        children: [
                          for (final option in const [
                            (
                              ThemeMode.system,
                              'System',
                              Icons.brightness_auto_outlined,
                            ),
                            (
                              ThemeMode.light,
                              'Light',
                              Icons.light_mode_outlined,
                            ),
                            (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                          ])
                            RadioListTile<ThemeMode>(
                              value: option.$1,
                              title: Text(option.$2),
                              secondary: Icon(option.$3),
                              contentPadding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionSurface(
                child: AppEmptyState(
                  icon: Icons.tune_rounded,
                  title: 'More settings arrive with their backend phases',
                  message: 'Notification and privacy controls are not shown until their server-side support exists.',
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
