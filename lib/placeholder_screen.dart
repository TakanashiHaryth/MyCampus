import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'shared_widgets.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

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
              PageHeader(title: title, subtitle: message),
              const SizedBox(height: AppSpacing.xl),
              SectionSurface(
                child: AppEmptyState(
                  icon: icon,
                  title: '$title is integration-ready',
                  message: 'The navigation and responsive page boundary are ready. Data and actions will be added in the scheduled feature phase.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
