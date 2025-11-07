// controller/auth_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';

class AuthController extends GetxController {
  // Login Fields
  var email = ''.obs;
  var password = ''.obs;
  var isLoggedIn = false.obs;

  // Registration Fields
  var fullName = ''.obs;
  var registerEmail = ''.obs;
  var registerPassword = ''.obs;
  var confirmPassword = ''.obs;

  // Current logged-in user
  var currentUser = Rxn<UserModel>();

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _checkAutoLogin();
  }

  // AUTO LOGIN ON APP START
  void _checkAutoLogin() {
    final userJson = _prefs.getString('currentUser');
    if (userJson != null) {
      try {
        final userMap =
            Map<String, dynamic>.from(jsonDecode(userJson) as Map<String, dynamic>);
        currentUser.value = UserModel.fromJson(userMap);
        isLoggedIn.value = true;
        Get.offAllNamed('/home');
      } catch (e) {
        print("Auto-login failed: $e");
      }
    }
  }

  // REGISTER FUNCTION
  void registerUser() async {
    // Validate
    if (fullName.isEmpty ||
        registerEmail.isEmpty ||
        registerPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar('Error', 'All fields are required',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (registerPassword.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Optional: Simple email format check
    if (!GetUtils.isEmail(registerEmail.value)) {
      Get.snackbar('Error', 'Enter a valid email',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Create user
    final newUser = UserModel(
      fullName: fullName.value,
      email: registerEmail.value,
      password: registerPassword.value,
    );

    // Save to SharedPreferences
    await _prefs.setString('currentUser', jsonEncode(newUser.toJson()));

    Get.snackbar('Success', 'Account created!',
        backgroundColor: Colors.green, colorText: Colors.white);
    Get.offAllNamed('/login');
  }

  // LOGIN FUNCTION
  void login() async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Fill in all fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final userJson = _prefs.getString('currentUser');
    if (userJson == null) {
      Get.snackbar('Error', 'No account found. Please register.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      final userMap =
          Map<String, dynamic>.from(jsonDecode(userJson) as Map<String, dynamic>);
      final savedUser = UserModel.fromJson(userMap);

      if (savedUser.email == email.value &&
          savedUser.password == password.value) {
        currentUser.value = savedUser;
        isLoggedIn.value = true;
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Invalid email or password',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // LOGOUT
  void logout() async {
    await _prefs.remove('currentUser');
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}