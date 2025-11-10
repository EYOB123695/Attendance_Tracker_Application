// lib/feature/home/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../history/view/history_view.dart';
import '../../history/controller/history_controller.dart';
import '../../profile/view/profile_view.dart';
import '../../profile/controller/profile_controller.dart';
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
    // Initialize all controllers when HomeView is created
    // This ensures they're always available for notifications
    Get.put(HomeController(), permanent: true);
    Get.put(DashboardController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(ProfileController(), permanent: true);

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
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    // Refresh attendance status when this tab becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<HomeController>().loadToday();
    });
  }

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
              padding: const EdgeInsets.all(24),
              child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.isCheckedIn.value 
                        ? Icons.check_circle 
                        : controller.checkOutTime.isNotEmpty 
                            ? Icons.check_circle_outline 
                            : Icons.radio_button_unchecked,
                    size: 48,
                    color: controller.isCheckedIn.value 
                        ? Colors.green 
                        : controller.checkOutTime.isNotEmpty 
                            ? Colors.blue 
                            : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.status.value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (controller.checkInTime.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Check-in: ${controller.checkInTime.value}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  if (controller.checkOutTime.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Check-out: ${controller.checkOutTime.value}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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