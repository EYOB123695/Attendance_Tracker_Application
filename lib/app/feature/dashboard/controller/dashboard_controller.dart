// lib/feature/dashboard/controller/dashboard_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

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
    final all = service.getAllAttendance();
    final now = DateTime.now();

    // Weekly
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    weeklyDays.value = all.keys.where((date) {
      final d = DateTime.parse(date);
      return d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             d.isBefore(weekEnd.add(const Duration(days: 1))) &&
             all[date]!.checkOut != null;
    }).length;

    // Monthly (filtered)
    monthlyDays.value = all.keys.where((date) {
      final d = DateTime.parse(date);
      return d.year == selectedYear.value &&
             d.month == selectedMonth.value &&
             all[date]!.checkOut != null;
    }).length;

    // Total Time Worked (for selected month)
    Duration totalDuration = Duration.zero;
    all.entries.forEach((entry) {
      final d = DateTime.parse(entry.key);
      if (d.year == selectedYear.value &&
          d.month == selectedMonth.value &&
          entry.value.duration != null) {
        totalDuration += _parseDuration(entry.value.duration);
      }
    });
    totalTimeWorked.value = _formatDuration(totalDuration);
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