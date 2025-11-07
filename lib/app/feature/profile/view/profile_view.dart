// lib/feature/profile/view/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final user = Get.find<AuthController>().currentUser.value!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user.email),
              ),
            ),
            const SizedBox(height: 20),

            // Theme Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: controller.isDark.value,
                onChanged: (_) => controller.toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}