import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/errors/app_failure.dart';
import 'core/friendship_repository.dart';
import 'core/user_profile_repository.dart';
import 'models/friendship.dart';
import 'models/user_profile.dart';
import 'shared_widgets.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    required this.currentUid,
    required this.friendships,
    required this.profiles,
    super.key,
  });

  final String currentUid;
  final FriendshipRepository friendships;
  final UserProfileRepository profiles;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  final Map<String, Future<PublicUserProfile?>> _profileCache = {};
  late Stream<List<Friendship>> _accepted;
  late Stream<List<Friendship>> _incoming;
  late Stream<List<Friendship>> _outgoing;
  List<PublicUserProfile> _searchResults = const [];
  bool _searching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _connectStreams();
  }

  @override
  void didUpdateWidget(covariant FriendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUid != widget.currentUid ||
        oldWidget.friendships != widget.friendships) {
      _profileCache.clear();
      _connectStreams();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _connectStreams() {
    _accepted = widget.friendships.watchAccepted(widget.currentUid);
    _incoming = widget.friendships.watchIncomingRequests(widget.currentUid);
    _outgoing = widget.friendships.watchOutgoingRequests(widget.currentUid);
  }

  Future<PublicUserProfile?> _profileFor(String uid) {
    return _profileCache.putIfAbsent(
      uid,
      () => widget.profiles.getPublicProfile(uid),
    );
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.length < 3) {
      _showMessage('Enter at least 3 characters.');
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await widget.profiles.searchPublicProfiles(query);
      if (mounted) {
        setState(() {
          _hasSearched = true;
          _searchResults = results
              .where((profile) => profile.uid != widget.currentUid)
              .toList(growable: false);
        });
      }
    } catch (_) {
      if (mounted) _showMessage('Unable to search students right now.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(PublicUserProfile profile) async {
    try {
      await widget.friendships.sendRequest(
        currentUid: widget.currentUid,
        targetUid: profile.uid,
      );
      if (mounted) _showMessage('Friend request sent to ${profile.name}.');
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } catch (_) {
      if (mounted) _showMessage('Unable to send the friend request.');
    }
  }

  Future<void> _respond(Friendship friendship, bool accept) async {
    try {
      await widget.friendships.respondToRequest(
        friendshipId: friendship.id,
        currentUid: widget.currentUid,
        accept: accept,
      );
      if (mounted) {
        _showMessage(accept ? 'Friend request accepted.' : 'Request declined.');
      }
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } catch (_) {
      if (mounted) _showMessage('Unable to update that request.');
    }
  }

  Future<void> _remove(Friendship friendship, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove $name?'),
        content: const Text(
          'You will no longer share friend-only campus updates with each other.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep friend'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove friend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.friendships.removeFriend(
        friendshipId: friendship.id,
        currentUid: widget.currentUid,
      );
      if (mounted) _showMessage('$name was removed from your friends.');
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } catch (_) {
      if (mounted) _showMessage('Unable to remove this friend.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Friends',
                subtitle:
                    'Find students and manage schedule-sharing connections.',
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add a friend',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Search by exact Student ID or username. Private account details stay hidden.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 520;
                        final field = TextField(
                          controller: _searchController,
                          enabled: !_searching,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: const InputDecoration(
                            labelText: 'Student ID or username',
                            hintText: 'MMR2008 or aiman',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        );
                        final button = ElevatedButton.icon(
                          onPressed: _searching ? null : _search,
                          icon: _searching
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search_rounded),
                          label: const Text('Search'),
                        );
                        if (narrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              field,
                              const SizedBox(height: AppSpacing.sm),
                              button,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: field),
                            const SizedBox(width: AppSpacing.sm),
                            button,
                          ],
                        );
                      },
                    ),
                    if (_hasSearched) ...[
                      const SizedBox(height: AppSpacing.md),
                      if (_searchResults.isEmpty)
                        const AppEmptyState(
                          icon: Icons.person_search_outlined,
                          title: 'No student found',
                          message: 'Check the exact Student ID or username and try again.',
                          compact: true,
                        )
                      else
                        for (final profile in _searchResults)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: UserAvatar(
                              name: profile.name,
                              imageUrl: profile.avatarUrl,
                            ),
                            title: Text(profile.name),
                            subtitle: Text(
                              '${profile.studentId} • ${profile.className}',
                            ),
                            trailing: OutlinedButton.icon(
                              onPressed: () => _sendRequest(profile),
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Add'),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _RelationshipSection(
                title: 'Friend requests',
                stream: _incoming,
                currentUid: widget.currentUid,
                profileFor: _profileFor,
                emptyTitle: 'No incoming requests',
                emptyMessage:
                    'New friend requests will appear here in realtime.',
                incoming: true,
                onRespond: _respond,
              ),
              const SizedBox(height: AppSpacing.lg),
              _RelationshipSection(
                title: 'Your friends',
                stream: _accepted,
                currentUid: widget.currentUid,
                profileFor: _profileFor,
                emptyTitle: 'No friends yet',
                emptyMessage:
                    'Add friends to share schedules and campus updates.',
                onRemove: _remove,
              ),
              const SizedBox(height: AppSpacing.lg),
              _RelationshipSection(
                title: 'Sent requests',
                stream: _outgoing,
                currentUid: widget.currentUid,
                profileFor: _profileFor,
                emptyTitle: 'No pending requests',
                emptyMessage:
                    'Requests waiting for a response will appear here.',
                outgoing: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationshipSection extends StatelessWidget {
  const _RelationshipSection({
    required this.title,
    required this.stream,
    required this.currentUid,
    required this.profileFor,
    required this.emptyTitle,
    required this.emptyMessage,
    this.incoming = false,
    this.outgoing = false,
    this.onRespond,
    this.onRemove,
  });

  final String title;
  final Stream<List<Friendship>> stream;
  final String currentUid;
  final Future<PublicUserProfile?> Function(String uid) profileFor;
  final String emptyTitle;
  final String emptyMessage;
  final bool incoming;
  final bool outgoing;
  final Future<void> Function(Friendship friendship, bool accept)? onRespond;
  final Future<void> Function(Friendship friendship, String name)? onRemove;

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<Friendship>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const AppErrorState(
                  title: 'Unable to load friendships',
                  message: 'Check your connection and Firestore access.',
                  compact: true,
                );
              }
              if (!snapshot.hasData) return const AppLoadingState(rows: 2);
              final relationships = snapshot.data!;
              if (relationships.isEmpty) {
                return AppEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: emptyTitle,
                  message: emptyMessage,
                  compact: true,
                );
              }
              return Column(
                children: [
                  for (
                    var index = 0;
                    index < relationships.length;
                    index++
                  ) ...[
                    _RelationshipTile(
                      friendship: relationships[index],
                      currentUid: currentUid,
                      profileFuture: profileFor(
                        relationships[index].otherUserId(currentUid),
                      ),
                      incoming: incoming,
                      outgoing: outgoing,
                      onRespond: onRespond,
                      onRemove: onRemove,
                    ),
                    if (index != relationships.length - 1) const Divider(),
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

class _RelationshipTile extends StatelessWidget {
  const _RelationshipTile({
    required this.friendship,
    required this.currentUid,
    required this.profileFuture,
    required this.incoming,
    required this.outgoing,
    this.onRespond,
    this.onRemove,
  });

  final Friendship friendship;
  final String currentUid;
  final Future<PublicUserProfile?> profileFuture;
  final bool incoming;
  final bool outgoing;
  final Future<void> Function(Friendship friendship, bool accept)? onRespond;
  final Future<void> Function(Friendship friendship, String name)? onRemove;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PublicUserProfile?>(
      future: profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.name ?? 'Campus student';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: UserAvatar(name: name, imageUrl: profile?.avatarUrl),
          title: Text(name),
          subtitle: Text(
            profile == null
                ? snapshot.hasError
                      ? 'Profile unavailable'
                      : 'Loading profile…'
                : '${profile.studentId} • ${profile.className}',
          ),
          trailing: incoming
              ? Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    IconButton(
                      tooltip: 'Decline request',
                      onPressed: () => onRespond?.call(friendship, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    IconButton(
                      tooltip: 'Accept request',
                      onPressed: () => onRespond?.call(friendship, true),
                      icon: const Icon(Icons.check_rounded),
                    ),
                  ],
                )
              : outgoing
              ? const StatusBadge(label: 'Pending', tone: AppColors.warning)
              : PopupMenuButton<String>(
                  tooltip: 'Friend actions',
                  onSelected: (value) {
                    if (value == 'remove') {
                      onRemove?.call(friendship, name);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_outlined),
                          SizedBox(width: AppSpacing.sm),
                          Text('Remove friend'),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
