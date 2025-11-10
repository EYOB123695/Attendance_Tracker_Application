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

  // Add a new session to a date (for check-in)
  Future<void> addCheckIn(String date, String checkInTime) async {
    final key = _key(date);
    final existing = getAttendance(date);
    
    // Create new session
    final newSession = AttendanceSession(checkIn: checkInTime);
    
    // Add to existing sessions or create new list (create a new list to avoid modifying the original)
    final sessions = existing != null 
        ? List<AttendanceSession>.from(existing.sessions)
        : <AttendanceSession>[];
    sessions.add(newSession);
    
    final updated = AttendanceModel(sessions: sessions);
    await _prefs.setString(key, jsonEncode(updated.toJson()));
    print('✅ [AttendanceService] Check-in added. Total sessions for $date: ${sessions.length}');
  }

  // Update the last session with check-out (for check-out)
  Future<void> addCheckOut(String date, String checkOutTime, String duration) async {
    final key = _key(date);
    final existing = getAttendance(date);
    
    if (existing == null || existing.sessions.isEmpty) {
      print('❌ [AttendanceService] No check-in found for $date');
      return;
    }
    
    // Update the last (most recent) session
    final sessions = List<AttendanceSession>.from(existing.sessions);
    if (sessions.isNotEmpty) {
      final lastSession = sessions.last;
      final updatedSession = AttendanceSession(
        checkIn: lastSession.checkIn,
        checkOut: checkOutTime,
        duration: duration,
      );
      sessions[sessions.length - 1] = updatedSession;
    }
    
    final updated = AttendanceModel(sessions: sessions);
    await _prefs.setString(key, jsonEncode(updated.toJson()));
    print('✅ [AttendanceService] Check-out added. Total sessions for $date: ${sessions.length}');
  }

  Future<void> saveAttendance(String date, AttendanceModel data) async {
    final key = _key(date);
    final jsonData = jsonEncode(data.toJson());
    print('📝 [AttendanceService] ========== SAVING ATTENDANCE ==========');
    print('📝 [AttendanceService] Date: $date');
    print('📝 [AttendanceService] Key: $key');
    print('📝 [AttendanceService] Sessions count: ${data.sessions.length}');
    
    // Check existing records before saving - store them to verify they persist
    final allBefore = getAllAttendance();
    final beforeDates = allBefore.keys.toList();
    print('📝 [AttendanceService] Records BEFORE save: ${allBefore.length}');
    print('📝 [AttendanceService] Existing dates: $beforeDates');
    
    // Save the new/updated record
    await _prefs.setString(key, jsonData);
    print('✅ [AttendanceService] Attendance saved successfully');
    
    // Verify it was saved
    final saved = _prefs.getString(key);
    if (saved != null) {
      print('✅ [AttendanceService] Verification: Data exists in storage');
    } else {
      print('❌ [AttendanceService] Verification: Data NOT found in storage!');
    }
    
    // Check existing records after saving
    final allAfter = getAllAttendance();
    final afterDates = allAfter.keys.toList();
    print('📝 [AttendanceService] Records AFTER save: ${allAfter.length}');
    print('📝 [AttendanceService] All dates now: $afterDates');
    
    // Verify old records still exist
    final missingDates = beforeDates.where((d) => d != date && !afterDates.contains(d)).toList();
    if (missingDates.isNotEmpty) {
      print('❌ [AttendanceService] ⚠️ WARNING: Missing dates after save: $missingDates');
      print('❌ [AttendanceService] This should NOT happen - old records should persist!');
    } else {
      print('✅ [AttendanceService] All previous records are still present');
    }
    
    print('📝 [AttendanceService] ========== SAVE COMPLETE ==========');
  }

  AttendanceModel? getAttendance(String date) {
    final jsonStr = _prefs.getString(_key(date));
    if (jsonStr == null) return null;
    return AttendanceModel.fromJson(jsonDecode(jsonStr));
  }

  Map<String, AttendanceModel> getAllAttendance() {
    print('📖 [AttendanceService] Getting all attendance records...');
    final Map<String, AttendanceModel> records = {};
    final allKeys = _prefs.getKeys();
    print('📖 [AttendanceService] Total keys in storage: ${allKeys.length}');
    print('📖 [AttendanceService] All keys: ${allKeys.toList()}');
    
    int attendanceKeysCount = 0;
    int validRecordsCount = 0;
    int invalidRecordsCount = 0;
    int totalSessions = 0;
    
    for (final key in allKeys) {
      if (key.startsWith(_prefix)) {
        attendanceKeysCount++;
        final date = key.substring(_prefix.length);
        print('📖 [AttendanceService] Processing attendance key: $key (date: $date)');
        
        // Read directly from SharedPreferences to avoid recursion
        final jsonStr = _prefs.getString(key);
        if (jsonStr != null) {
          try {
            final model = AttendanceModel.fromJson(jsonDecode(jsonStr));
            records[date] = model;
            validRecordsCount++;
            totalSessions += model.sessions.length;
            print('📖 [AttendanceService] ✅ Valid record for $date: ${model.sessions.length} sessions');
            for (var i = 0; i < model.sessions.length; i++) {
              final s = model.sessions[i];
              print('   Session ${i + 1}: In=${s.checkIn}, Out=${s.checkOut ?? "N/A"}, Duration=${s.duration ?? "N/A"}');
            }
          } catch (e) {
            invalidRecordsCount++;
            print('📖 [AttendanceService] ❌ Error parsing record for $date: $e');
          }
        } else {
          invalidRecordsCount++;
          print('📖 [AttendanceService] ❌ No data found for key: $key');
        }
      }
    }
    print('📖 [AttendanceService] Summary:');
    print('   - Found $attendanceKeysCount attendance keys');
    print('   - Valid records: $validRecordsCount');
    print('   - Invalid records: $invalidRecordsCount');
    print('   - Total sessions across all dates: $totalSessions');
    print('📖 [AttendanceService] Returning ${records.length} valid records');
    print('📖 [AttendanceService] Record dates: ${records.keys.toList()}');
    return records;
  }

  String get today => DateTime.now().toIso8601String().split('T').first;
}