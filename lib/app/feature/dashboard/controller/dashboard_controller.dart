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
  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();
    updateSummary();
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