// lib/feature/history/controller/history_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/service/attendance_service.dart';
import '../../../../core/utils/month_year_picker.dart';

import 'package:intl/intl.dart';

class HistoryController extends GetxController {
  final AttendanceService service = Get.find();
  var records = <Map<String, String>>[].obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;
  var expandedIndex = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  void toggleExpand(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = null;
    } else {
      expandedIndex.value = index;
    }
  }

  void loadRecords() {
    final all = service.getAllAttendance();
    final filtered = all.entries.where((e) {
      final d = DateTime.parse(e.key);
      return d.year == selectedYear.value && d.month == selectedMonth.value;
    }).toList();

    filtered.sort((a, b) => b.key.compareTo(a.key)); // latest first

    records.value = filtered.map((e) {
      final m = e.value;
      return {
        'date': DateFormat('MMM dd, yyyy').format(DateTime.parse(e.key)),
        'dateKey': e.key, // Store original date key for reference
        'checkIn': m.checkIn ?? '-',
        'checkOut': m.checkOut ?? '-',
        'duration': m.duration ?? '-',
      };
    }).toList();
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
      loadRecords();
    }
  }
}