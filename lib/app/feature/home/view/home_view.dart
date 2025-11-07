// lib/feature/home/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../history/view/history_view.dart';
import '../../profile/view/profile_view.dart';
import '../../../feature/auth/controller/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // List of pages (lazy-loaded)
  static final List<Widget> _pages = [
    const _HomeContent(),      // Home tab
    const DashboardView(),     // Dashboard tab
    const HistoryView(),       // History tab
    const ProfileView(),       // Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize HomeController only once
    Get.put(HomeController());

    // Selected tab index
    final selectedIndex = 0.obs;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          ['Attendance', 'Dashboard', 'History', 'Profile'][selectedIndex.value],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: selectedIndex.value,
        children: _pages,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}

// Extracted Home Tab Content (so controller is reused)
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Today: ${DateTime.now().toIso8601String().split('T').first}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() => Column(
                children: [
                  Text(
                    controller.status.value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (controller.checkInTime.isNotEmpty)
                    Text('Check-in: ${controller.checkInTime.value}', style: const TextStyle(fontSize: 16)),
                  if (controller.checkOutTime.isNotEmpty)
                    Text('Check-out: ${controller.checkOutTime.value}', style: const TextStyle(fontSize: 16)),
                ],
              )),
            ),
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.isCheckedIn.value ? null : controller.checkIn,
                  child: const Text('Check In', style: TextStyle(fontSize: 16)),
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.isCheckedIn.value ? controller.checkOut : null,
                  child: const Text('Check Out', style: TextStyle(fontSize: 16)),
                )),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}