import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/app_dependencies.dart';
import 'models/dashboard_models.dart';
import 'models/friendship.dart';
import 'models/user_profile.dart';
import 'shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.profile,
    required this.dependencies,
    required this.onNavigate,
    super.key,
  });

  final UserProfile profile;
  final AppDependencies dependencies;
  final ValueChanged<int> onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<List<DashboardSchedule>> _schedules;
  late Stream<List<DashboardNotice>> _notices;
  late Stream<List<Friendship>> _friends;

  @override
  void initState() {
    super.initState();
    _connectStreams();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.uid != widget.profile.uid ||
        oldWidget.dependencies != widget.dependencies) {
      _connectStreams();
    }
  }

  void _connectStreams() {
    _schedules = widget.dependencies.dashboard
        .watchTodaySchedules(widget.profile.uid)
        .asBroadcastStream(onCancel: (subscription) => subscription.cancel());
    _notices = widget.dependencies.dashboard
        .watchRecentNotices(widget.profile.uid)
        .asBroadcastStream(onCancel: (subscription) => subscription.cancel());
    _friends = widget.dependencies.friendships.watchAccepted(
      widget.profile.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title:
                    '${_greeting()}, ${widget.profile.name.split(' ').first}',
                subtitle: "Here's what is happening across your campus today.",
              ),
              const SizedBox(height: AppSpacing.xl),
              _SummaryGrid(
                schedules: _schedules,
                notices: _notices,
                friends: _friends,
                onNavigate: widget.onNavigate,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TodayScheduleSection(stream: _schedules),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  final assignments = const _AssignmentsPreview();
                  final notices = _NoticesPreview(stream: _notices);
                  if (!wide) {
                    return Column(
                      children: [
                        assignments,
                        const SizedBox(height: AppSpacing.lg),
                        notices,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: assignments),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: notices),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.schedules,
    required this.notices,
    required this.friends,
    required this.onNavigate,
  });

  final Stream<List<DashboardSchedule>> schedules;
  final Stream<List<DashboardNotice>> notices;
  final Stream<List<Friendship>> friends;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - (columns - 1) * AppSpacing.md) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: width,
              child: StreamBuilder<List<DashboardSchedule>>(
                stream: schedules,
                builder: (context, snapshot) => _SummaryCard(
                  icon: Icons.calendar_today_outlined,
                  label: "Today's classes",
                  value: snapshot.hasError
                      ? '!'
                      : snapshot.hasData
                      ? '${snapshot.data!.length}'
                      : '—',
                  context: snapshot.hasError
                      ? 'Unable to sync'
                      : snapshot.hasData
                      ? 'Scheduled today'
                      : 'Loading schedule',
                  onTap: () => onNavigate(2),
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: _SummaryCard(
                icon: Icons.task_alt_rounded,
                label: 'Assignments',
                value: '—',
                context: 'Data source pending',
                onTap: () => onNavigate(3),
              ),
            ),
            SizedBox(
              width: width,
              child: StreamBuilder<List<DashboardNotice>>(
                stream: notices,
                builder: (context, snapshot) => _SummaryCard(
                  icon: Icons.campaign_outlined,
                  label: 'Recent notices',
                  value: snapshot.hasError
                      ? '!'
                      : snapshot.hasData
                      ? '${snapshot.data!.length}'
                      : '—',
                  context: snapshot.hasError
                      ? 'Unable to sync'
                      : snapshot.hasData
                      ? 'Latest announcements'
                      : 'Loading notices',
                  onTap: () => onNavigate(4),
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: StreamBuilder<List<Friendship>>(
                stream: friends,
                builder: (context, snapshot) => _SummaryCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Friends',
                  value: snapshot.hasError
                      ? '!'
                      : snapshot.hasData
                      ? '${snapshot.data!.length}'
                      : '—',
                  context: snapshot.hasError
                      ? 'Unable to sync'
                      : snapshot.hasData
                      ? 'Accepted connections'
                      : 'Loading friends',
                  onTap: () => onNavigate(5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatefulWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String context;
  final VoidCallback onTap;

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '${widget.label}: ${widget.value}. ${widget.context}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: AppMotion.normal,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered ? scheme.surfaceContainer : scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          widget.icon,
                          color: scheme.onPrimaryContainer,
                          size: 21,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.context,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
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

class _TodayScheduleSection extends StatelessWidget {
  const _TodayScheduleSection({required this.stream});

  final Stream<List<DashboardSchedule>> stream;

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Today's schedule",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          StreamBuilder<List<DashboardSchedule>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const AppErrorState(
                  title: 'Unable to load schedules',
                  message: 'Check your connection and Firestore access, then try again.',
                  compact: true,
                );
              }
              if (!snapshot.hasData) return const AppLoadingState(rows: 2);
              final schedules = snapshot.data!;
              if (schedules.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'Nothing scheduled for today',
                  message: 'Your shared classes for today will appear here.',
                  compact: true,
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < schedules.length; index++) ...[
                    _ScheduleRow(schedule: schedules[index]),
                    if (index != schedules.length - 1) const Divider(),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.schedule});

  final DashboardSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              _time(schedule.startAt),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Container(
            width: 3,
            height: 44,
            decoration: BoxDecoration(
              color: _statusTone(schedule.status, scheme),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  [schedule.subject, schedule.room]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: _titleCase(schedule.status),
            tone: _statusTone(schedule.status, scheme),
          ),
        ],
      ),
    );
  }

  String _time(DateTime? date) {
    if (date == null) return 'TBA';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }
}

class _AssignmentsPreview extends StatelessWidget {
  const _AssignmentsPreview();

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upcoming assignments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const AppEmptyState(
            icon: Icons.assignment_outlined,
            title: 'Assignment data is not connected yet',
            message: 'This panel is ready for the assignment repository in its scheduled phase.',
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _NoticesPreview extends StatelessWidget {
  const _NoticesPreview({required this.stream});

  final Stream<List<DashboardNotice>> stream;

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Recent notices', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<DashboardNotice>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const AppErrorState(
                  title: 'Unable to load notices',
                  message: 'Check your connection and Firestore access.',
                  compact: true,
                );
              }
              if (!snapshot.hasData) return const AppLoadingState(rows: 2);
              final notices = snapshot.data!;
              if (notices.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notices yet',
                  message: 'Announcements shared with you will appear here.',
                  compact: true,
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < notices.length; index++) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.campaign_outlined),
                      title: Text(
                        notices[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        notices[index].message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (index != notices.length - 1) const Divider(),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Color _statusTone(String status, ColorScheme scheme) {
  return switch (status) {
    'cancelled' => scheme.error,
    'rescheduled' => AppColors.warning,
    'completed' => AppColors.success,
    _ => scheme.primary,
  };
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
