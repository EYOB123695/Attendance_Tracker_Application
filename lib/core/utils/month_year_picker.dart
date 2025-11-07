// lib/core/utils/month_year_picker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<Map<String, int>?> showMonthYearPicker({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
}) async {
  int? selectedYear = initialYear;
  int? selectedMonth = initialMonth;

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Select Month & Year'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            // Year Picker
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (c, i) {
                  final year = DateTime.now().year - 5 + i;
                  return ListTile(
                    title: Text('$year'),
                    selected: year == selectedYear,
                    onTap: () => selectedYear = year,
                  );
                },
              ),
            ),
            const Divider(),
            // Month Picker
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 2,
                children: List.generate(12, (i) {
                  final month = i + 1;
                  final monthName = DateTime(2020, month).toString().split(' ')[0].substring(5, 7);
                  return InkWell(
                    onTap: () => selectedMonth = month,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: selectedMonth == month ? Colors.deepPurple : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat.MMM().format(DateTime(2020, month)),
                        style: TextStyle(
                          color: selectedMonth == month ? Colors.white : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, {'year': selectedYear, 'month': selectedMonth}),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  if (selectedYear == null || selectedMonth == null) return null;
  return {'year': selectedYear!, 'month': selectedMonth!};
}