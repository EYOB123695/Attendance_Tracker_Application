import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      theme: ThemeData.light(),    // light theme
      darkTheme: ThemeData.dark(), // dark theme
      themeMode: ThemeMode.system, // can toggle later via Profile
      initialRoute: AppPages.initial, // Login screen
      getPages: AppPages.routes,       // all GetX routes
    );
  }
}
