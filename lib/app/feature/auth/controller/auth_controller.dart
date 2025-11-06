import 'package:get/get.dart';

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

  // LOGIN FUNCTION
  void login() {
    if (email.isNotEmpty && password.isNotEmpty) {
      // TODO: replace with real storage/auth logic later
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Error', 'Please fill in all fields');
    }
  }

  // REGISTER FUNCTION
  void registerUser() {
    if (fullName.isEmpty ||
        registerEmail.isEmpty ||
        registerPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    if (registerPassword.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    // TODO: Save user info locally or send to backend later
    Get.snackbar('Success', 'Account created successfully');
    Get.offAllNamed('/login');
  }
}
