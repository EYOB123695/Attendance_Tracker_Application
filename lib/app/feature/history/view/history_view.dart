// lib/feature/history/view/history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/history_controller.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    // Refresh records when this tab becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📜 [HistoryView] Tab became visible, refreshing records...');
      Get.find<HistoryController>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Controller is already initialized in HomeView
    // Use Get.find() to get existing instance, or create if doesn't exist
    final controller = Get.find<HistoryController>();

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
        print('🔄 [HistoryView] Obx() rebuilding - Records count: ${controller.records.length}');
        if (controller.records.isEmpty) {
          return const Center(
            child: Text(
              'No records for this month',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = controller.records[i];
            final isExpanded = controller.expandedIndex.value == i;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => controller.toggleExpand(i),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                      title: Row(
                        children: [
                          Text(
                            r['date']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          // Show session number if there are multiple sessions on the same day
                          if (controller.records.where((rec) => rec['dateKey'] == r['dateKey']).length > 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Session ${(int.parse(r['sessionIndex']!) + 1)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.login, size: 16, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text('In: ${r['checkIn']}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.logout, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text('Out: ${r['checkOut']}'),
                                  ],
                                ),
                              ],
                            ),
                            if (r['duration'] != '-' && r['duration'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Duration: ${r['duration']}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _buildDetailRow('Date', r['date']!),
                            const SizedBox(height: 8),
                            _buildDetailRow('Check-In Time', r['checkIn']!),
                            const SizedBox(height: 8),
                            _buildDetailRow('Check-Out Time', r['checkOut']!),
                            if (r['duration'] != '-' && r['duration'] != null) ...[
                              const SizedBox(height: 8),
                              _buildDetailRow('Total Duration', r['duration']!),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}