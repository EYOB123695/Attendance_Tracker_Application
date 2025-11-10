import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[400],
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Obx(() => TextField(
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person),
                            errorText: controller.fullNameError.value,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: controller.validateFullName,
                        )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            errorText: controller.registerEmailError.value,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: controller.validateRegisterEmail,
                        )),
                        const SizedBox(height: 16),
                        Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                errorText: controller.registerPasswordError.value,
                                helperText: controller.registerPassword.value.isEmpty
                                    ? 'Minimum 6 characters'
                                    : 'Password strength: ${controller.passwordStrength.value}',
                                helperMaxLines: 2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              onChanged: controller.validateRegisterPassword,
                            ),
                            if (controller.registerPassword.value.isNotEmpty &&
                                controller.registerPasswordError.value == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: controller.passwordStrength.value == 'Weak'
                                            ? 0.33
                                            : controller.passwordStrength.value == 'Medium'
                                                ? 0.66
                                                : 1.0,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          controller.passwordStrength.value == 'Weak'
                                              ? Colors.red
                                              : controller.passwordStrength.value == 'Medium'
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller.passwordStrength.value,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: controller.passwordStrength.value == 'Weak'
                                            ? Colors.red
                                            : controller.passwordStrength.value == 'Medium'
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorText: controller.confirmPasswordError.value,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          onChanged: controller.validateConfirmPassword,
                        )),
                        const SizedBox(height: 24),
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: controller.isRegisterValid 
                                  ? Colors.deepPurple 
                                  : Colors.grey,
                            ),
                            onPressed: controller.isRegisterValid 
                                ? controller.registerUser 
                                : null,
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        )),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Get.offNamed('/login'),
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
