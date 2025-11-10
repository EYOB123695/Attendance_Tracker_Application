// lib/feature/profile/controller/profile_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  var isDark = false.obs;
  static const String _themeKey = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    // Defer theme loading to avoid build-time errors
    Future.microtask(() => _loadTheme());
  }

  SharedPreferences get _prefs => Get.find<SharedPreferences>();

  void _loadTheme() {
    final savedTheme = _prefs.getBool(_themeKey);
    if (savedTheme != null) {
      isDark.value = savedTheme;
      // Use Future.microtask to avoid calling during build
      Future.microtask(() {
        Get.changeThemeMode(savedTheme ? ThemeMode.dark : ThemeMode.light);
      });
    } else {
      // Use system theme if no saved preference
      isDark.value = Get.isDarkMode;
    }
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    _prefs.setBool(_themeKey, isDark.value);
    // Use Future.microtask to avoid calling during build
    Future.microtask(() {
      Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    });
  }
}