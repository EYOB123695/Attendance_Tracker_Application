// lib/core/model/attendance_model.dart
class AttendanceModel {
  final String? checkIn;
  final String? checkOut;
  final String? duration;

  AttendanceModel({this.checkIn, this.checkOut, this.duration});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      checkIn: json['checkIn'] as String?,
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