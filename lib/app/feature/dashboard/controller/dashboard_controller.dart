// lib/feature/dashboard/controller/dashboard_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/service/attendance_service.dart';
import '../../../../core/utils/month_year_picker.dart';

class DashboardController extends GetxController {
  final AttendanceService service = Get.find();

  var weeklyDays = 0.obs;
  var monthlyDays = 0.obs;
  var totalTimeWorked = '0h 0m'.obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();
    print('📊 [DashboardController] onInit() called - Controller initialized');
    updateSummary();
  }

  Duration _parseDuration(String? durationStr) {
    if (durationStr == null || durationStr.isEmpty) return Duration.zero;
    try {
      // Format: "Xh Ym"
      final parts = durationStr.split(' ');
      int hours = 0;
      int minutes = 0;
      for (var part in parts) {
        if (part.endsWith('h')) {
          hours = int.tryParse(part.substring(0, part.length - 1)) ?? 0;
        } else if (part.endsWith('m')) {
          minutes = int.tryParse(part.substring(0, part.length - 1)) ?? 0;
        }
      }
      return Duration(hours: hours, minutes: minutes);
    } catch (e) {
      return Duration.zero;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  void updateSummary() {
    print('📊 [DashboardController] updateSummary() called');
    final all = service.getAllAttendance();
    print('📊 [DashboardController] Retrieved ${all.length} attendance records');
    final now = DateTime.now();

    // Weekly - count unique days with at least one completed session
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weeklyDaysSet = <String>{};
    all.entries.forEach((entry) {
      final d = DateTime.parse(entry.key);
      if (d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          d.isBefore(weekEnd.add(const Duration(days: 1)))) {
        // Check if this day has at least one completed session
        final hasCompletedSession = entry.value.sessions
            .any((s) => s.checkOut != null);
        if (hasCompletedSession) {
          weeklyDaysSet.add(entry.key); // Add date key to set (unique days)
        }
      }
    });
    weeklyDays.value = weeklyDaysSet.length;

    // Monthly - count unique days with at least one completed session
    final monthlyDaysSet = <String>{};
    all.entries.forEach((entry) {
      final d = DateTime.parse(entry.key);
      if (d.year == selectedYear.value && d.month == selectedMonth.value) {
        // Check if this day has at least one completed session
        final hasCompletedSession = entry.value.sessions
            .any((s) => s.checkOut != null);
        if (hasCompletedSession) {
          monthlyDaysSet.add(entry.key); // Add date key to set (unique days)
        }
      }
    });
    monthlyDays.value = monthlyDaysSet.length;

    // Total Time Worked (for selected month) - sum all session durations
    Duration totalDuration = Duration.zero;
    all.entries.forEach((entry) {
      final d = DateTime.parse(entry.key);
      if (d.year == selectedYear.value && d.month == selectedMonth.value) {
        // Sum durations of all completed sessions
        for (final session in entry.value.sessions) {
          if (session.duration != null && session.duration!.isNotEmpty) {
            totalDuration += _parseDuration(session.duration);
          }
        }
      }
    });
    totalTimeWorked.value = _formatDuration(totalDuration);
    
    print('📊 [DashboardController] Summary updated:');
    print('   - Weekly Days: ${weeklyDays.value}');
    print('   - Monthly Days: ${monthlyDays.value}');
    print('   - Total Time: ${totalTimeWorked.value}');
  }

  void showFilterDialog(BuildContext context) async {
    final result = await showMonthYearPicker(
      context: context,
      initialYear: selectedYear.value,
      initialMonth: selectedMonth.value,
    );
    if (result != null) {
      selectedYear.value = result['year']!;
      selectedMonth.value = result['month']!;
      updateSummary();
    }
  }
}