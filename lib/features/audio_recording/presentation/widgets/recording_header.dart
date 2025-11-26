import 'package:flutter/material.dart';

class RecordingHeader extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final String title;

  const RecordingHeader({
    super.key,
    required this.nameController,
    required this.onRename,
    required this.onDelete,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onRename,
          icon: const Icon(Icons.save),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
