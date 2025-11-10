// main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/feature/auth/controller/auth_controller.dart';
import 'core/service/attendance_service.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs);

  // Initialize services
  await Get.putAsync<AttendanceService>(() async => await AttendanceService().init());

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController()); // Auth controller

    // Load saved theme preference
    final prefs = Get.find<SharedPreferences>();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}