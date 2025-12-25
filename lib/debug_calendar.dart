import 'package:flutter/material.dart';

/// Minimal calendar widget for debugging layout issues
class DebugCalendar extends StatelessWidget {
  const DebugCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Calendar'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Calendar header
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '2025年12月',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Week days header
            Container(
              height: 40,
              child: Row(
                children: ['日', '一', '二', '三', '四', '五', '六']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // Calendar grid
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: List.generate(6, (weekIndex) {
                    return Expanded(
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final dayNumber = weekIndex * 7 + dayIndex + 1;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: dayNumber <= 31
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  dayNumber <= 31 ? '$dayNumber' : '',
                                  style: TextStyle(
                                    color: dayNumber <= 31
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
