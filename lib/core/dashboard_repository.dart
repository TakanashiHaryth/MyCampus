import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dashboard_models.dart';

abstract interface class DashboardRepository {
  Stream<List<DashboardSchedule>> watchTodaySchedules(String uid);
  Stream<List<DashboardNotice>> watchRecentNotices(String uid);
}

class FirestoreDashboardRepository implements DashboardRepository {
  FirestoreDashboardRepository(this._firestore, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _now;

  @override
  Stream<List<DashboardSchedule>> watchTodaySchedules(String uid) {
    final current = _now();
    final start = DateTime(current.year, current.month, current.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('schedules')
        .where('sharedWith', arrayContains: uid)
        .where(
          'startAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          isLessThan: Timestamp.fromDate(end),
        )
        .orderBy('startAt')
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    DashboardSchedule.fromMap(document.id, document.data()),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<DashboardNotice>> watchRecentNotices(String uid) {
    return _firestore
        .collection('notices')
        .where('targetUserIds', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    DashboardNotice.fromMap(document.id, document.data()),
              )
              .toList(growable: false),
        );
  }
}
