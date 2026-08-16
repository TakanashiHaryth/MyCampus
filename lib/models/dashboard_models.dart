import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _dashboardDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

class DashboardSchedule {
  const DashboardSchedule({
    required this.id,
    required this.title,
    required this.subject,
    required this.status,
    this.startAt,
    this.endAt,
    this.room,
  });

  final String id;
  final String title;
  final String subject;
  final String status;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? room;

  factory DashboardSchedule.fromMap(String id, Map<String, Object?> map) {
    return DashboardSchedule(
      id: id,
      title: map['title'] as String? ?? 'Untitled class',
      subject: map['subject'] as String? ?? '',
      status: map['status'] as String? ?? 'scheduled',
      startAt: _dashboardDate(map['startAt']),
      endAt: _dashboardDate(map['endAt']),
      room: map['room'] as String?,
    );
  }
}

class DashboardNotice {
  const DashboardNotice({
    required this.id,
    required this.title,
    required this.message,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final DateTime? createdAt;

  factory DashboardNotice.fromMap(String id, Map<String, Object?> map) {
    return DashboardNotice(
      id: id,
      title: map['title'] as String? ?? 'Notice',
      message: map['message'] as String? ?? '',
      createdAt: _dashboardDate(map['createdAt']),
    );
  }
}
