enum AttendanceStatus { present, late, absent, unknown }

class AttendanceModel {
  final String id;
  final String userId;
  final String companyId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? breakStartTime;
  final DateTime? breakEndTime;
  final AttendanceStatus status;
  final String? checkInImageUrl;
  final String? checkOutImageUrl;

  // Joined field – populated when fetching with profile data
  final String? employeeName;
  final String? employeeId;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.breakStartTime,
    this.breakEndTime,
    required this.status,
    this.checkInImageUrl,
    this.checkOutImageUrl,
    this.employeeName,
    this.employeeId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    AttendanceStatus parseStatus(String? s) {
      switch (s) {
        case 'present':
          return AttendanceStatus.present;
        case 'late':
          return AttendanceStatus.late;
        case 'absent':
          return AttendanceStatus.absent;
        default:
          return AttendanceStatus.unknown;
      }
    }

    // Support nested profiles object from join
    final profile = json['profiles'] as Map<String, dynamic>?;

    return AttendanceModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String).toLocal()
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String).toLocal()
          : null,
      breakStartTime: json['break_start_time'] != null
          ? DateTime.parse(json['break_start_time'] as String).toLocal()
          : null,
      breakEndTime: json['break_end_time'] != null
          ? DateTime.parse(json['break_end_time'] as String).toLocal()
          : null,
      status: parseStatus(json['status'] as String?),
      checkInImageUrl: json['check_in_image_url'] as String?,
      checkOutImageUrl: json['check_out_image_url'] as String?,
      employeeName: profile != null
          ? profile['name'] as String?
          : json['employee_name'] as String?,
      employeeId: profile != null
          ? profile['employee_id'] as String?
          : json['employee_id'] as String?,
    );
  }

  // ── computed getters ──────────────────────────────────────────────────────

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;
  bool get isOnBreak =>
      breakStartTime != null && breakEndTime == null && isCheckedIn;

  Duration get workingDuration {
    if (checkInTime == null) return Duration.zero;
    final end = checkOutTime ?? DateTime.now();
    final raw = end.difference(checkInTime!);
    return raw - breakDuration;
  }

  Duration get breakDuration {
    if (breakStartTime == null) return Duration.zero;
    final end = breakEndTime ?? (isOnBreak ? DateTime.now() : breakStartTime!);
    return end.difference(breakStartTime!);
  }

  String get statusLabel {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.unknown:
        return 'Unknown';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'company_id': companyId,
        'date': date.toIso8601String().split('T').first,
        'check_in_time': checkInTime?.toIso8601String(),
        'check_out_time': checkOutTime?.toIso8601String(),
        'break_start_time': breakStartTime?.toIso8601String(),
        'break_end_time': breakEndTime?.toIso8601String(),
        'status': statusLabel.toLowerCase(),
        'check_in_image_url': checkInImageUrl,
        'check_out_image_url': checkOutImageUrl,
      };
}
