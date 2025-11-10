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
    print('📜 [HistoryController] onInit() called - Controller initialized');
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
    print('📜 [HistoryController] ========== LOAD RECORDS STARTED ==========');
    print('📜 [HistoryController] Filter: Year=${selectedYear.value}, Month=${selectedMonth.value}');
    
    final all = service.getAllAttendance();
    print('📜 [HistoryController] Retrieved ${all.length} total records from service');
    print('📜 [HistoryController] All record dates: ${all.keys.toList()}');
    
    final filtered = all.entries.where((entry) {
      try {
        final d = DateTime.parse(entry.key);
        final matches = d.year == selectedYear.value && d.month == selectedMonth.value;
        if (matches) {
          print('📜 [HistoryController] ✅ Record matches filter: ${entry.key}');
        } else {
          print('📜 [HistoryController] ❌ Record does NOT match filter: ${entry.key} (Year: ${d.year}, Month: ${d.month})');
        }
        return matches;
      } catch (error) {
        print('📜 [HistoryController] ⚠️ Error parsing date ${entry.key}: $error');
        return false;
      }
    }).toList();

    print('📜 [HistoryController] Filtered to ${filtered.length} records');
    filtered.sort((a, b) => b.key.compareTo(a.key)); // latest first

    // Flatten sessions - each session becomes a separate record
    final newRecords = <Map<String, String>>[];
    for (final entry in filtered) {
      final dateKey = entry.key;
      final dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(dateKey));
      final model = entry.value;
      
      // Create a record for each session
      for (var i = 0; i < model.sessions.length; i++) {
        final session = model.sessions[i];
        final record = {
          'date': dateStr,
          'dateKey': dateKey,
          'sessionIndex': i.toString(),
          'checkIn': session.checkIn,
          'checkOut': session.checkOut ?? '-',
          'duration': session.duration ?? '-',
        };
        newRecords.add(record);
        print('📜 [HistoryController] Mapped session ${i + 1} for $dateKey: $record');
      }
    }
    
    // Sort by date (newest first) and then by session index (newest first)
    newRecords.sort((a, b) {
      final dateCompare = b['dateKey']!.compareTo(a['dateKey']!);
      if (dateCompare != 0) return dateCompare;
      return int.parse(b['sessionIndex']!).compareTo(int.parse(a['sessionIndex']!));
    });
    
    // Assign to trigger Obx() rebuild
    print('📜 [HistoryController] Previous records count: ${records.length}');
    print('📜 [HistoryController] New records count: ${newRecords.length}');
    records.assignAll(newRecords);
    print('📜 [HistoryController] Final records count: ${records.length}');
    print('📜 [HistoryController] Records assigned, Obx() should rebuild now');
    print('📜 [HistoryController] ========== LOAD RECORDS COMPLETED ==========');
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