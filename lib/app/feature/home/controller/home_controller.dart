// lib/feature/home/controller/home_controller.dart
import 'package:get/get.dart';

import '../../../../core/model/attendance_model.dart';
import '../../../../core/service/attendance_service.dart';


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

    if (record == null) {
      status.value = 'Not checked in';
      isCheckedIn.value = false;
    } else if (record.checkOut == null) {
      checkInTime.value = record.checkIn!;
      status.value = 'Checked in at ${record.checkIn}';
      isCheckedIn.value = true;
    } else {
      checkOutTime.value = record.checkOut!;
      status.value = 'Checked out at ${record.checkOut}';
      isCheckedIn.value = false;
    }
  }

  void checkIn() {
    final time = _formatTime(DateTime.now());
    final today = service.today;
    final record = AttendanceModel(checkIn: time);

    service.saveAttendance(today, record);

    checkInTime.value = time;
    status.value = 'Checked in at $time';
    isCheckedIn.value = true;
  }

  void checkOut() {
    final time = _formatTime(DateTime.now());
    final today = service.today;
    final record = service.getAttendance(today);

    if (record?.checkIn == null) return;

    final checkInDt = _parseTime(record!.checkIn!);
    final checkOutDt = _parseTime(time);
    final duration = checkOutDt.difference(checkInDt);
    final durationStr = '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';

    final updated = AttendanceModel(
      checkIn: record.checkIn,
      checkOut: time,
      duration: durationStr,
    );

    service.saveAttendance(today, updated);

    checkOutTime.value = time;
    status.value = 'Checked out at $time';
    isCheckedIn.value = false;
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  DateTime _parseTime(String time) {
    final [h, m] = time.split(':').map(int.parse).toList();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }
}