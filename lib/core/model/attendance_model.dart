// lib/core/model/attendance_model.dart

// Single attendance session
class AttendanceSession {
  final String checkIn;
  final String? checkOut;
  final String? duration;

  AttendanceSession({
    required this.checkIn,
    this.checkOut,
    this.duration,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String?,
      duration: json['duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'duration': duration,
    };
  }
}

// Daily attendance record (contains multiple sessions)
class AttendanceModel {
  final List<AttendanceSession> sessions;

  AttendanceModel({required this.sessions});

  // Legacy support - for backward compatibility
  String? get checkIn => sessions.isNotEmpty ? sessions.first.checkIn : null;
  String? get checkOut => sessions.isNotEmpty && sessions.last.checkOut != null 
      ? sessions.last.checkOut 
      : null;
  String? get duration => sessions.isNotEmpty && sessions.last.duration != null
      ? sessions.last.duration
      : null;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // Support both old format (single session) and new format (list of sessions)
    if (json.containsKey('sessions')) {
      final sessionsList = json['sessions'] as List;
      return AttendanceModel(
        sessions: sessionsList
            .map((s) => AttendanceSession.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
    } else {
      // Legacy format - convert to new format
      final session = AttendanceSession(
        checkIn: json['checkIn'] as String? ?? '',
        checkOut: json['checkOut'] as String?,
        duration: json['duration'] as String?,
      );
      return AttendanceModel(sessions: [session]);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
  }
}