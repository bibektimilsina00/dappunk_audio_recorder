import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  final double sliderValue;
  final Duration total;
  final Duration position;
  final double volume;
  final String? filteredPath;
  final String originalPath;
  final String Function(Duration) formatDuration;
  final void Function(String) onPlay;
  final VoidCallback onPause;
  final void Function(double) onSeek;
  final void Function(double) onVolumeChange;

  const PlaybackControls({
    super.key,
    required this.sliderValue,
    required this.total,
    required this.position,
    required this.volume,
    required this.filteredPath,
    required this.originalPath,
    required this.formatDuration,
    required this.onPlay,
    required this.onPause,
    required this.onSeek,
    required this.onVolumeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Playback Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onPlay(filteredPath ?? originalPath),
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.blue,
                  iconSize: 32,
                  tooltip: 'Play',
                ),
                IconButton(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause),
                  color: Colors.blue,
                  iconSize: 32,
                  tooltip: 'Pause',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(value: sliderValue, onChanged: onSeek, activeColor: Colors.blue),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(position)),
              Text(formatDuration(total)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.grey),
            Expanded(
              child: Slider(
                value: volume,
                min: 0.0,
                max: 1.0,
                onChanged: onVolumeChange,
                activeColor: Colors.blue,
              ),
            ),
            Text('${(volume * 100).toInt()}%'),
          ],
        ),
      ],
    );
  }
}
