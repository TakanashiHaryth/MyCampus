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

  void _cancelEditing() {
    _resetControllers();
    setState(() => _editing = false);
  }

  Future<void> _showPhotoRequirement() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_upload_outlined),
        title: const Text('Profile photo setup required'),
        content: const Text(
          'A synced profile photo needs secure cloud storage. Photo uploads '
          'will be available after Firebase Storage is approved and configured.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated.')));
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final pagePadding = compact ? AppSpacing.md : AppSpacing.lg;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            AppSpacing.lg,
            pagePadding,
            AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.readableContentWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PageHeader(
                      title: 'Profile',
                      subtitle: 'Manage the campus details people use to recognize you.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ProfileHero(
                      profile: widget.profile,
                      editing: _editing,
                      onEdit: () => setState(() => _editing = true),
                      onChangePhoto: _showPhotoRequirement,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSwitcher(
                      duration: AppMotion.normal,
                      switchInCurve: AppMotion.standard,
                      switchOutCurve: AppMotion.standard,
                      child: _editing
                          ? _EditProfileForm(
                              key: const ValueKey('edit-profile'),
                              name: _name,
                              username: _username,
                              studentId: _studentId,
                              className: _className,
                              course: _course,
                              email: widget.profile.studentEmail,
                              saving: _saving,
                              onCancel: _cancelEditing,
                              onSave: _save,
                            )
                          : _ProfileDetails(
                              key: const ValueKey('profile-details'),
                              profile: widget.profile,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.editing,
    required this.onEdit,
    required this.onChangePhoto,
  });

  final UserProfile profile;
  final bool editing;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final identity = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(
                    name: profile.name,
                    imageUrl: profile.avatarUrl,
                    radius: compact ? 44 : 52,
                  ),
                  Positioned(
                    right: -AppSpacing.xs,
                    bottom: -AppSpacing.xs,
                    child: IconButton.filled(
                      tooltip: 'Change profile photo',
                      onPressed: onChangePhoto,
                      icon: const Icon(Icons.photo_camera_outlined, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '@${profile.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const StatusBadge(
                          label: 'Student',
                          tone: AppColors.success,
                        ),
                        Text(
                          '${profile.studentId}  •  ${profile.className}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      profile.course,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );

          final editButton = OutlinedButton.icon(
            onPressed: editing ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(editing ? 'Editing profile' : 'Edit profile'),
          );

          return Container(
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      identity,
                      const SizedBox(height: AppSpacing.lg),
                      editButton,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: AppSpacing.xl),
                      editButton,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final joined = profile.createdAt == null
        ? 'Not available'
        : MaterialLocalizations.of(context)
              .formatMediumDate(profile.createdAt!.toLocal());
    final updated = profile.updatedAt == null
        ? 'Not available'
        : MaterialLocalizations.of(context)
              .formatMediumDate(profile.updatedAt!.toLocal());

    final sections = [
      _InformationSection(
        icon: Icons.school_outlined,
        title: 'Academic information',
        subtitle: 'Details used across classes and friend search.',
        items: [
          _InformationItem('Student ID', profile.studentId),
          _InformationItem('Class', profile.className),
          _InformationItem('Course', profile.course),
        ],
      ),
      _InformationSection(
        icon: Icons.manage_accounts_outlined,
        title: 'Account information',
        subtitle: 'Your private sign-in and public campus identity.',
        items: [
          _InformationItem('Username', '@${profile.username}'),
          _InformationItem('Student email', profile.studentEmail),
          _InformationItem('Member since', joined),
          _InformationItem('Last updated', updated),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              sections.first,
              const SizedBox(height: AppSpacing.lg),
              sections.last,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: sections.first),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: sections.last),
          ],
        );
      },
    );
  }
}

class _InformationSection extends StatelessWidget {
  const _InformationSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_InformationItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer, size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < items.length; index++) ...[
            _InformationRow(item: items[index]),
            if (index != items.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class _InformationItem {
  const _InformationItem(this.label, this.value);

  final String label;
  final String value;
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({required this.item});

  final _InformationItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SelectableText(
            item.value.trim().isEmpty ? 'Not provided' : item.value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm({
    required this.name,
    required this.username,
    required this.studentId,
    required this.className,
    required this.course,
    required this.email,
    required this.saving,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final TextEditingController name;
  final TextEditingController username;
  final TextEditingController studentId;
  final TextEditingController className;
  final TextEditingController course;
  final String email;
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Keep these details accurate so classmates can identify you.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ResponsiveFields(
            children: [
              _ProfileField(
                controller: name,
                label: 'Full name',
                icon: Icons.badge_outlined,
                enabled: !saving,
              ),
              _ProfileField(
                controller: username,
                label: 'Username',
                icon: Icons.alternate_email_rounded,
                helperText: 'Used by friends to find you.',
                enabled: !saving,
                validator: _validateUsername,
              ),
              _ProfileField(
                controller: studentId,
                label: 'Student ID',
                icon: Icons.credit_card_rounded,
                helperText: 'Used by friends to find you.',
                enabled: !saving,
                validator: _validateStudentId,
              ),
              _ProfileField(
                controller: className,
                label: 'Class',
                icon: Icons.groups_2_outlined,
                enabled: !saving,
              ),
              _ProfileField(
                controller: course,
                label: 'Course',
                icon: Icons.school_outlined,
                enabled: !saving,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '$email\nYour sign-in email is managed by Firebase Authentication.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton(
                onPressed: saving ? null : onCancel,
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: saving ? null : onSave,
                child: saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter Username.';
    if (!RegExp(r'^[A-Za-z0-9._-]{3,30}$').hasMatch(trimmed)) {
      return 'Use 3–30 letters, numbers, dots, dashes or underscores.';
    }
    return null;
  }

  static String? _validateStudentId(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter Student ID.';
    if (!RegExp(r'^[A-Za-z0-9-]{3,30}$').hasMatch(trimmed)) {
      return 'Use 3–30 letters, numbers or dashes.';
    }
    return null;
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.helperText,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final String? helperText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) return 'Enter $label.';
            return null;
          },
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
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
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
