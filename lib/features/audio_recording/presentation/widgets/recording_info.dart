import 'package:flutter/material.dart';

import '../../domain/entities/recording.dart';

class RecordingInfo extends StatelessWidget {
  final Recording recording;
  final String Function(DateTime) formatDate;
  final String Function(Duration) formatDuration;

  const RecordingInfo({
    super.key,
    required this.recording,
    required this.formatDate,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recording.name.isNotEmpty ? recording.name : 'Untitled Recording',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  formatDate(recording.timestamp),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${formatDuration(recording.duration)}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
