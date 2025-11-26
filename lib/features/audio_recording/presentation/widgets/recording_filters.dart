import 'package:flutter/material.dart';

import '../../../audio_filter/domain/entities/filter_type.dart';

class RecordingFilters extends StatelessWidget {
  final bool isApplying;
  final Future<void> Function(FilterType) onFilterApply;

  const RecordingFilters({
    super.key,
    required this.isApplying,
    required this.onFilterApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio Filters',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (isApplying)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FilterType.values.map((filterType) {
            return ChoiceChip(
              label: Text(filterType.name),
              selected: false,
              onSelected: isApplying ? null : (_) => onFilterApply(filterType),
              avatar: const Icon(Icons.filter_alt, size: 18),
            );
          }).toList(),
        ),
      ],
    );
  }
}
