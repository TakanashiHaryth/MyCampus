import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/app_dependencies.dart';
import 'core/errors/app_failure.dart';
import 'core/theme_controller.dart';
import 'dashboard_screen.dart';
import 'friends_screen.dart';
import 'models/auth_session.dart';
import 'models/user_profile.dart';
import 'placeholder_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'shared_widgets.dart';

class AuthenticatedShell extends StatefulWidget {
  const AuthenticatedShell({
    required this.session,
    required this.profile,
    required this.dependencies,
    required this.themeController,
    super.key,
  });

  final AuthSession session;
  final UserProfile profile;
  final AppDependencies dependencies;
  final ThemeController themeController;

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = false;
  bool _sidebarInitialized = false;

  static const _mainDestinations = [
    _Destination(
      'Dashboard',
      Icons.dashboard_outlined,
      Icons.dashboard_rounded,
    ),
    _Destination('Classes', Icons.school_outlined, Icons.school_rounded),
    _Destination(
      'Schedule',
      Icons.calendar_today_outlined,
      Icons.calendar_today_rounded,
    ),
    _Destination('Assignments', Icons.task_outlined, Icons.task_rounded),
    _Destination('Notices', Icons.campaign_outlined, Icons.campaign_rounded),
    _Destination('Friends', Icons.people_outline_rounded, Icons.people_rounded),
    _Destination(
      'Notifications',
      Icons.notifications_none_rounded,
      Icons.notifications_rounded,
    ),
  ];

  static const _settings = _Destination(
    'Settings',
    Icons.settings_outlined,
    Icons.settings_rounded,
  );

  void _select(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out of My Campus?'),
        content: const Text(
          'You will need to sign in again to access your campus data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay signed in'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.dependencies.auth.signOut();
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 720;
        if (mobile) {
          return Scaffold(
            appBar: _MobileTopBar(
              title: _currentTitle,
              profile: widget.profile,
              onNotifications: () => _select(6),
              onProfile: () => _select(8),
            ),
            drawer: _MobileDrawer(
              selectedIndex: _selectedIndex,
              profile: widget.profile,
              onSelect: (index) {
                Navigator.of(context).pop();
                _select(index);
              },
              onSignOut: () {
                Navigator.of(context).pop();
                _signOut();
              },
            ),
            body: _pageForSelection(),
          );
        }

        final sidebarExpanded = _sidebarInitialized
            ? _sidebarExpanded
            : constraints.maxWidth >= 1100;

        return Scaffold(
          body: Row(
            children: [
              _DesktopSidebar(
                expanded: sidebarExpanded,
                selectedIndex: _selectedIndex,
                profile: widget.profile,
                onToggle: () => setState(() {
                  _sidebarInitialized = true;
                  _sidebarExpanded = !sidebarExpanded;
                }),
                onSelect: _select,
                onSignOut: _signOut,
              ),
              Expanded(
                child: Column(
                  children: [
                    _DesktopTopBar(
                      title: _currentTitle,
                      profile: widget.profile,
                      onNotifications: () => _select(6),
                      onProfile: () => _select(8),
                    ),
                    Expanded(child: _pageForSelection()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String get _currentTitle {
    if (_selectedIndex <= 6) return _mainDestinations[_selectedIndex].label;
    if (_selectedIndex == 7) return 'Settings';
    return 'Profile';
  }

  Widget _pageForSelection() {
    return switch (_selectedIndex) {
      0 => DashboardScreen(
        profile: widget.profile,
        dependencies: widget.dependencies,
        onNavigate: _select,
      ),
      1 => const FeaturePlaceholderScreen(
        title: 'Classes',
        message: 'Browse and manage the classes you join.',
        icon: Icons.school_outlined,
      ),
      2 => const FeaturePlaceholderScreen(
        title: 'Schedule',
        message: 'Week and list views will be connected in the schedule phase.',
        icon: Icons.calendar_today_outlined,
      ),
      3 => const FeaturePlaceholderScreen(
        title: 'Assignments',
        message:
            'Deadline-focused assignment views await a defined backend schema.',
        icon: Icons.task_outlined,
      ),
      4 => const FeaturePlaceholderScreen(
        title: 'Notices',
        message: 'Realtime notice history will be expanded after schedule data is stable.',
        icon: Icons.campaign_outlined,
      ),
      5 => FriendsScreen(
        currentUid: widget.session.uid,
        friendships: widget.dependencies.friendships,
        profiles: widget.dependencies.profiles,
      ),
      6 => const FeaturePlaceholderScreen(
        title: 'Notifications',
        message: 'FCM remains intentionally deferred until realtime Firestore sync is stable.',
        icon: Icons.notifications_none_rounded,
      ),
      7 => SettingsScreen(themeController: widget.themeController),
      _ => ProfileScreen(
        profile: widget.profile,
        repository: widget.dependencies.profiles,
      ),
    };
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.expanded,
    required this.selectedIndex,
    required this.profile,
    required this.onToggle,
    required this.onSelect,
    required this.onSignOut,
  });

  final bool expanded;
  final int selectedIndex;
  final UserProfile profile;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      width: expanded ? 248 : 80,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 76,
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  if (expanded) const SizedBox(width: AppSpacing.md),
                  IconButton(
                    tooltip: expanded ? 'Collapse sidebar' : 'Expand sidebar',
                    onPressed: onToggle,
                    icon: const Icon(Icons.menu_rounded),
                  ),
                  if (expanded) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'MY CAMPUS',
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (
                    var index = 0;
                    index < _AuthenticatedShellState._mainDestinations.length;
                    index++
                  )
                    _SidebarItem(
                      destination:
                          _AuthenticatedShellState._mainDestinations[index],
                      selected: selectedIndex == index,
                      expanded: expanded,
                      onTap: () => onSelect(index),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                children: [
                  const Divider(),
                  _SidebarItem(
                    destination: _AuthenticatedShellState._settings,
                    selected: selectedIndex == 7,
                    expanded: expanded,
                    onTap: () => onSelect(7),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SidebarProfile(
                    profile: profile,
                    expanded: expanded,
                    onProfile: () => onSelect(8),
                    onSettings: () => onSelect(7),
                    onSignOut: onSignOut,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final item = Material(
      color: selected ? scheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (expanded) const SizedBox(width: 14),
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 22,
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              if (expanded) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    destination.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: expanded ? item : Tooltip(message: destination.label, child: item),
    );
  }
}

class _SidebarProfile extends StatelessWidget {
  const _SidebarProfile({
    required this.profile,
    required this.expanded,
    required this.onProfile,
    required this.onSettings,
    required this.onSignOut,
  });

  final UserProfile profile;
  final bool expanded;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      onSelected: (value) {
        if (value == 'profile') onProfile();
        if (value == 'settings') onSettings();
        if (value == 'logout') onSignOut();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('View profile')),
        PopupMenuItem(value: 'settings', child: Text('Settings')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Container(
        height: expanded ? 68 : 52,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? AppSpacing.sm : AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            UserAvatar(
              name: profile.name,
              imageUrl: profile.avatarUrl,
              radius: 20,
            ),
            if (expanded) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      profile.className,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.title,
    required this.profile,
    required this.onNotifications,
    required this.onProfile,
  });

  final String title;
  final UserProfile profile;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
          Tooltip(
            message: 'View profile',
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onProfile,
              child: UserAvatar(
                name: profile.name,
                imageUrl: profile.avatarUrl,
                radius: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _MobileTopBar({
    required this.title,
    required this.profile,
    required this.onNotifications,
    required this.onProfile,
  });

  final String title;
  final UserProfile profile;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onProfile,
            child: UserAvatar(
              name: profile.name,
              imageUrl: profile.avatarUrl,
              radius: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({
    required this.selectedIndex,
    required this.profile,
    required this.onSelect,
    required this.onSignOut,
  });

  final int selectedIndex;
  final UserProfile profile;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.school_rounded),
              title: Text(
                'MY CAMPUS',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(letterSpacing: 0.8),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (
                    var index = 0;
                    index < _AuthenticatedShellState._mainDestinations.length;
                    index++
                  )
                    ListTile(
                      selected: selectedIndex == index,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      leading: Icon(
                        selectedIndex == index
                            ? _AuthenticatedShellState
                                  ._mainDestinations[index]
                                  .selectedIcon
                            : _AuthenticatedShellState
                                  ._mainDestinations[index]
                                  .icon,
                      ),
                      title: Text(
                        _AuthenticatedShellState._mainDestinations[index].label,
                      ),
                      onTap: () => onSelect(index),
                    ),
                  const Divider(),
                  ListTile(
                    selected: selectedIndex == 7,
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () => onSelect(7),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: UserAvatar(
                name: profile.name,
                imageUrl: profile.avatarUrl,
              ),
              title: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(profile.className),
              onTap: () => onSelect(8),
            ),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: onSignOut,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
