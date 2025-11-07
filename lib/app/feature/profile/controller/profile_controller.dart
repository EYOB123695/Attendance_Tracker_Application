// lib/feature/profile/controller/profile_controller.dart
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  var isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = Get.isDarkMode;
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }
}