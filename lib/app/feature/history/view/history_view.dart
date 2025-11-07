// lib/feature/history/view/history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/history_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => controller.showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return const Center(child: Text('No records for this month'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.records.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = controller.records[i];
            return Card(
              child: ListTile(
                title: Text(r['date']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('In: ${r['checkIn']}'),
                    Text('Out: ${r['checkOut']}'),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}