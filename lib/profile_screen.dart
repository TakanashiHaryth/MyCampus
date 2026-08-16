import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/errors/app_failure.dart';
import 'core/user_profile_repository.dart';
import 'models/user_profile.dart';
import 'shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.profile,
    required this.repository,
    super.key,
  });

  final UserProfile profile;
  final UserProfileRepository repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _studentId;
  late final TextEditingController _className;
  late final TextEditingController _course;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _username = TextEditingController();
    _studentId = TextEditingController();
    _className = TextEditingController();
    _course = TextEditingController();
    _resetControllers();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile && !_editing) _resetControllers();
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _studentId.dispose();
    _className.dispose();
    _course.dispose();
    super.dispose();
  }

  void _resetControllers() {
    _name.text = widget.profile.name;
    _username.text = widget.profile.username;
    _studentId.text = widget.profile.studentId;
    _className.text = widget.profile.className;
    _course.text = widget.profile.course;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.repository.updateProfile(
        widget.profile.copyWith(
          name: _name.text.trim(),
          username: _username.text.trim(),
          studentId: _studentId.text.trim(),
          className: _className.text.trim(),
          course: _course.text.trim(),
        ),
      );
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated.')));
      }
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update your profile.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Profile',
                  subtitle: 'Keep your public campus identity accurate.',
                  action: _editing
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => setState(() => _editing = true),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit profile'),
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ProfileHeader(profile: widget.profile),
                const SizedBox(height: AppSpacing.lg),
                SectionSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Personal information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _ResponsiveFields(
                        children: [
                          _field(_name, 'Full name', Icons.badge_outlined),
                          _field(
                            _username,
                            'Username',
                            Icons.alternate_email_rounded,
                          ),
                          _readOnlyField(
                            widget.profile.studentEmail,
                            'Student email',
                            Icons.mail_outline_rounded,
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        'Academic information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _ResponsiveFields(
                        children: [
                          _field(
                            _studentId,
                            'Student ID',
                            Icons.credit_card_rounded,
                          ),
                          _field(_className, 'Class', Icons.groups_2_outlined),
                          _field(_course, 'Course', Icons.school_outlined),
                        ],
                      ),
                      if (_editing) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () {
                                      _resetControllers();
                                      setState(() => _editing = false);
                                    },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _saving ? null : _save,
                              child: _saving
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : const Text('Save changes'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      enabled: _editing && !_saving,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Enter $label.';
        if (label == 'Username' &&
            !RegExp(r'^[A-Za-z0-9._-]{3,30}$').hasMatch(value.trim())) {
          return 'Use 3–30 letters, numbers, dots, dashes or underscores.';
        }
        if (label == 'Student ID' &&
            !RegExp(r'^[A-Za-z0-9-]{3,30}$').hasMatch(value.trim())) {
          return 'Use 3–30 letters, numbers or dashes.';
        }
        return null;
      },
    );
  }

  Widget _readOnlyField(String value, String label, IconData icon) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        helperText: 'Managed by Firebase Authentication.',
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.md,
        children: [
          UserAvatar(
            name: profile.name,
            imageUrl: profile.avatarUrl,
            radius: 42,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('${profile.studentId} • ${profile.className}'),
              const SizedBox(height: AppSpacing.xs),
              Text(profile.course),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 840
            ? 3
            : constraints.maxWidth >= 540
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - (columns - 1) * AppSpacing.md) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(growable: false),
        );
      },
    );
  }
}
