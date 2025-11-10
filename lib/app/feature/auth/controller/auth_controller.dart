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
  
  // Login Validation Errors
  var emailError = Rxn<String>();
  var passwordError = Rxn<String>();

  // Registration Fields
  var fullName = ''.obs;
  var registerEmail = ''.obs;
  var registerPassword = ''.obs;
  var confirmPassword = ''.obs;
  
  // Registration Validation Errors
  var fullNameError = Rxn<String>();
  var registerEmailError = Rxn<String>();
  var registerPasswordError = Rxn<String>();
  var confirmPasswordError = Rxn<String>();
  
  // Password Strength
  var passwordStrength = 'Weak'.obs; // Weak, Medium, Strong

  // Current logged-in user
  var currentUser = Rxn<UserModel>();
  
  // Computed properties for button enabled states
  bool get isLoginValid {
    return email.value.isNotEmpty &&
           password.value.isNotEmpty &&
           emailError.value == null &&
           passwordError.value == null;
  }
  
  bool get isRegisterValid {
    return fullName.value.isNotEmpty &&
           registerEmail.value.isNotEmpty &&
           registerPassword.value.isNotEmpty &&
           confirmPassword.value.isNotEmpty &&
           fullNameError.value == null &&
           registerEmailError.value == null &&
           registerPasswordError.value == null &&
           confirmPasswordError.value == null;
  }

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

  // Validation Methods
  void validateLoginEmail(String value) {
    email.value = value;
    if (value.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(value)) {
      emailError.value = 'Enter a valid email';
    } else {
      emailError.value = null;
    }
  }
  
  void validateLoginPassword(String value) {
    password.value = value;
    if (value.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = null;
    }
  }
  
  void validateFullName(String value) {
    fullName.value = value;
    if (value.isEmpty) {
      fullNameError.value = 'Full name is required';
    } else if (value.length < 3) {
      fullNameError.value = 'Name must be at least 3 characters';
    } else {
      fullNameError.value = null;
    }
  }
  
  void validateRegisterEmail(String value) {
    registerEmail.value = value;
    if (value.isEmpty) {
      registerEmailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(value)) {
      registerEmailError.value = 'Enter a valid email';
    } else {
      registerEmailError.value = null;
    }
  }
  
  void validateRegisterPassword(String value) {
    registerPassword.value = value;
    if (value.isEmpty) {
      registerPasswordError.value = 'Password is required';
      passwordStrength.value = 'Weak';
    } else if (value.length < 6) {
      registerPasswordError.value = 'Password must be at least 6 characters';
      passwordStrength.value = 'Weak';
    } else {
      registerPasswordError.value = null;
      // Calculate password strength
      int strength = 0;
      if (value.length >= 8) strength++;
      if (value.contains(RegExp(r'[A-Z]'))) strength++;
      if (value.contains(RegExp(r'[a-z]'))) strength++;
      if (value.contains(RegExp(r'[0-9]'))) strength++;
      if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
      
      if (strength <= 2) {
        passwordStrength.value = 'Weak';
      } else if (strength <= 4) {
        passwordStrength.value = 'Medium';
      } else {
        passwordStrength.value = 'Strong';
      }
    }
    // Re-validate confirm password if it's already filled
    if (confirmPassword.value.isNotEmpty) {
      validateConfirmPassword(confirmPassword.value);
    }
  }
  
  void validateConfirmPassword(String value) {
    confirmPassword.value = value;
    if (value.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
    } else if (value != registerPassword.value) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = null;
    }
  }

  // REGISTER FUNCTION
  void registerUser() async {
    // Validate all fields
    validateFullName(fullName.value);
    validateRegisterEmail(registerEmail.value);
    validateRegisterPassword(registerPassword.value);
    validateConfirmPassword(confirmPassword.value);
    
    if (!isRegisterValid) {
      Get.snackbar('Error', 'Please fix the errors',
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

    // Clear registration fields
    fullName.value = '';
    registerEmail.value = '';
    registerPassword.value = '';
    confirmPassword.value = '';
    fullNameError.value = null;
    registerEmailError.value = null;
    registerPasswordError.value = null;
    confirmPasswordError.value = null;

    Get.snackbar('Success', 'Account created successfully!',
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed('/login');
  }

  // LOGIN FUNCTION
  void login() async {
    // Validate fields
    validateLoginEmail(email.value);
    validateLoginPassword(password.value);
    
    if (!isLoginValid) {
      Get.snackbar('Error', 'Please fix the errors',
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
        // Clear login fields
        email.value = '';
        password.value = '';
        emailError.value = null;
        passwordError.value = null;
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