// lib/feature/dashboard/view/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => controller.showFilterDialog(context),
                icon: const Icon(Icons.filter_alt),
                label: Obx(() => Text(
                  '${DateFormat.MMMM().format(DateTime(controller.selectedYear.value, controller.selectedMonth.value))} ${controller.selectedYear.value}',
                )),
              ),
            ),
            const SizedBox(height: 20),

            // Weekly Card
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: Colors.blue),
                title: const Text('Weekly Attendance'),
                trailing: Obx(() => Text(
                  '${controller.weeklyDays.value} days',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.green),
                title: const Text('Monthly Attendance'),
                trailing: Obx(() => Text(
                  '${controller.monthlyDays.value} days',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}