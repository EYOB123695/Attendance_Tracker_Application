// lib/core/service/attendance_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/attendance_model.dart';

class AttendanceService extends GetxService {
  late SharedPreferences _prefs;
  static const String _prefix = 'attendance_';

  Future<AttendanceService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String _key(String date) => '$_prefix$date';

  Future<void> saveAttendance(String date, AttendanceModel data) async {
    await _prefs.setString(_key(date), jsonEncode(data.toJson()));
  }

  AttendanceModel? getAttendance(String date) {
    final jsonStr = _prefs.getString(_key(date));
    if (jsonStr == null) return null;
    return AttendanceModel.fromJson(jsonDecode(jsonStr));
  }

  Map<String, AttendanceModel> getAllAttendance() {
    final Map<String, AttendanceModel> records = {};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        final date = key.substring(_prefix.length);
        final model = getAttendance(date);
        if (model != null) records[date] = model;
      }
    }
    return records;
  }

  String get today => DateTime.now().toIso8601String().split('T').first;
}