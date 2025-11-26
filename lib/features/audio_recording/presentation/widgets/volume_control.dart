import 'package:flutter/material.dart';

class VolumeControl extends StatelessWidget {
  final double volume;
  final void Function(double) onChange;

  const VolumeControl({
    super.key,
    required this.volume,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Volume'),
        Expanded(
          child: Slider(value: volume, min: 0.0, max: 1.0, onChanged: onChange),
        ),
      ],
    );
  }
}
