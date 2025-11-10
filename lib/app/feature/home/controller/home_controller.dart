// lib/feature/home/controller/home_controller.dart
import 'package:get/get.dart';

import '../../../../core/model/attendance_model.dart';
import '../../../../core/service/attendance_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../history/controller/history_controller.dart';


class HomeController extends GetxController {
  final AttendanceService service = Get.find();

  var status = 'Not checked in'.obs;
  var checkInTime = ''.obs;
  var checkOutTime = ''.obs;
  var isCheckedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadToday();
  }

  void loadToday() {
    final today = service.today;
    final record = service.getAttendance(today);

    if (record == null || record.sessions.isEmpty) {
      status.value = 'Not checked in';
      checkInTime.value = '';
      checkOutTime.value = '';
      isCheckedIn.value = false;
    } else {
      // Get the last (most recent) session
      final lastSession = record.sessions.last;
      if (lastSession.checkOut == null) {
        // Currently checked in
        checkInTime.value = lastSession.checkIn;
        checkOutTime.value = '';
        status.value = 'Checked in at ${lastSession.checkIn}';
        isCheckedIn.value = true;
      } else {
        // Last session is completed
        checkInTime.value = lastSession.checkIn;
        checkOutTime.value = lastSession.checkOut!;
        status.value = 'Checked out at ${lastSession.checkOut}';
        isCheckedIn.value = false;
      }
    }
  }

  Future<void> checkIn() async {
    print('🟢 [HomeController] ========== CHECK IN STARTED ==========');
    final time = _formatTime(DateTime.now());
    final today = service.today;
    print('🟢 [HomeController] Time: $time, Date: $today');

    // Add new check-in session (don't overwrite existing sessions)
    print('🟢 [HomeController] Adding new check-in session...');
    await service.addCheckIn(today, time);
    print('🟢 [HomeController] Check-in session added, updating UI...');

    checkInTime.value = time;
    status.value = 'Checked in at $time';
    isCheckedIn.value = true;
    print('🟢 [HomeController] UI updated, notifying other controllers...');
    
    // Notify other controllers to refresh after data is saved
    _notifyAttendanceChanged();
    print('🟢 [HomeController] ========== CHECK IN COMPLETED ==========');
  }

  Future<void> checkOut() async {
    print('🔴 [HomeController] ========== CHECK OUT STARTED ==========');
    final time = _formatTime(DateTime.now());
    final today = service.today;
    print('🔴 [HomeController] Time: $time, Date: $today');
    
    final record = service.getAttendance(today);
    print('🔴 [HomeController] Existing record: ${record?.sessions.length ?? 0} sessions');

    if (record == null || record.sessions.isEmpty) {
      print('❌ [HomeController] No check-in found, cannot check out!');
      return;
    }

    // Get the last session (current check-in)
    final lastSession = record.sessions.last;
    if (lastSession.checkOut != null) {
      print('❌ [HomeController] Last session already has check-out!');
      return;
    }

    final checkInDt = _parseTime(lastSession.checkIn);
    final checkOutDt = _parseTime(time);
    final duration = checkOutDt.difference(checkInDt);
    final durationStr = '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    print('🔴 [HomeController] Duration calculated: $durationStr');

    // Update the last session with check-out
    print('🔴 [HomeController] Adding check-out to last session...');
    await service.addCheckOut(today, time, durationStr);
    print('🔴 [HomeController] Check-out added, updating UI...');

    checkOutTime.value = time;
    status.value = 'Checked out at $time';
    isCheckedIn.value = false;
    print('🔴 [HomeController] UI updated, notifying other controllers...');
    
    // Notify other controllers to refresh after data is saved
    _notifyAttendanceChanged();
    print('🔴 [HomeController] ========== CHECK OUT COMPLETED ==========');
  }

  /// Notifies Dashboard and History controllers to refresh their data
  void _notifyAttendanceChanged() {
    print('📢 [HomeController] _notifyAttendanceChanged() called');
    
    // Update immediately (synchronously) to ensure UI updates
    // Update Dashboard controller (should always exist now since initialized in HomeView)
    try {
      print('📊 [HomeController] Finding DashboardController...');
      final dashboardController = Get.find<DashboardController>();
      print('📊 [HomeController] DashboardController found, calling updateSummary()...');
      dashboardController.updateSummary();
      print('✅ [HomeController] DashboardController updated successfully');
    } catch (e) {
      print('⚠️ [HomeController] DashboardController not found: $e');
      // If not found, initialize it
      try {
        print('📊 [HomeController] Initializing DashboardController...');
        Get.put(DashboardController(), permanent: true);
        Get.find<DashboardController>().updateSummary();
        print('✅ [HomeController] DashboardController initialized and updated');
      } catch (e2) {
        print('❌ [HomeController] Failed to initialize DashboardController: $e2');
      }
    }

    // Update History controller (should always exist now since initialized in HomeView)
    try {
      print('📜 [HomeController] Finding HistoryController...');
      final historyController = Get.find<HistoryController>();
      print('📜 [HomeController] HistoryController found, calling loadRecords()...');
      historyController.loadRecords();
      print('✅ [HomeController] HistoryController updated successfully');
    } catch (e) {
      print('⚠️ [HomeController] HistoryController not found: $e');
      // If not found, initialize it
      try {
        print('📜 [HomeController] Initializing HistoryController...');
        Get.put(HistoryController(), permanent: true);
        Get.find<HistoryController>().loadRecords();
        print('✅ [HomeController] HistoryController initialized and updated');
      } catch (e2) {
        print('❌ [HomeController] Failed to initialize HistoryController: $e2');
      }
    }
    
    // Force a rebuild by using a small delay to ensure GetX processes the changes
    Future.delayed(const Duration(milliseconds: 100), () {
      print('🔄 [HomeController] Forcing UI refresh after delay...');
      try {
        Get.find<DashboardController>().updateSummary();
      } catch (e) {}
      try {
        Get.find<HistoryController>().loadRecords();
      } catch (e) {}
    });
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  DateTime _parseTime(String time) {
    final [h, m] = time.split(':').map(int.parse).toList();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }
}