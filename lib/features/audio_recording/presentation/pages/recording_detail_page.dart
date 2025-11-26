import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/recording.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import 'package:dappunk/features/audio_filter/domain/entities/filter_type.dart';

import '../widgets/filtered_audio_info.dart';
import '../widgets/playback_controls.dart';
import '../widgets/recording_filters.dart';
import '../widgets/recording_info.dart';

class RecordingDetailPage extends StatefulWidget {
  final Recording recording;

  const RecordingDetailPage({super.key, required this.recording});

  @override
  State<RecordingDetailPage> createState() => _RecordingDetailPageState();
}

class _RecordingDetailPageState extends State<RecordingDetailPage> {
  double _volume = 1.0;
  bool _isApplying = false;
  String? _filteredPath;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    final repo = context.read<RecordingBloc>().repository;

    _positionSub = repo.playbackPosition.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);
      }
    });

    _durationSub = repo.playbackDuration.listen((dur) {
      if (mounted) {
        setState(() => _duration = dur ?? widget.recording.duration);
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }

  String _generateOutputPath(String originalPath, String suffix) {
    final lastDotIndex = originalPath.lastIndexOf('.');
    if (lastDotIndex == -1) {
      return '${originalPath}_$suffix';
    }
    return '${originalPath.substring(0, lastDotIndex)}_$suffix${originalPath.substring(lastDotIndex)}';
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: widget.recording.name);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Recording'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter new name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      if (!mounted) return;
      context.read<RecordingBloc>().add(
        RenameRecordingEvent(widget.recording.id, controller.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording renamed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    controller.dispose();
  }

  Future<void> _delete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text(
          'Are you sure you want to delete this recording? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return;
      context.read<RecordingBloc>().add(
        DeleteRecordingEvent(widget.recording.id),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> _applyFilter(FilterType filterType) async {
    setState(() => _isApplying = true);

    final filterName = filterType.name.toLowerCase().replaceAll(' ', '_');
    final outputPath = _generateOutputPath(widget.recording.path, filterName);

    if (!mounted) return;
    context.read<RecordingBloc>().add(
      ApplyFilterEvent(
        id: widget.recording.id,
        path: widget.recording.path,
        outputPath: outputPath,
        filterName: filterType.name,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (File(outputPath).existsSync()) {
        setState(() {
          _filteredPath = outputPath;
          _isApplying = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${filterType.name} filter preview created'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isApplying = false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create filter preview. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _playRecording(String path) {
    context.read<RecordingBloc>().add(PlayRecordingEvent(path));
  }

  void _pausePlayback() {
    context.read<RecordingBloc>().add(const PausePlaybackEvent());
  }

  void _seekPlayback(double value) {
    final total = _duration == Duration.zero
        ? widget.recording.duration
        : _duration;
    final newPosition = Duration(
      milliseconds: (total.inMilliseconds * value).toInt(),
    );
    context.read<RecordingBloc>().add(SeekPlaybackEvent(newPosition));
  }

  void _setVolume(double value) {
    setState(() => _volume = value);
    context.read<RecordingBloc>().add(SetPlaybackVolumeEvent(value));
  }

  @override
  Widget build(BuildContext context) {
    final total = _duration == Duration.zero
        ? widget.recording.duration
        : _duration;
    final sliderValue = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recording.name.isNotEmpty
              ? widget.recording.name
              : 'Recording Detail',
        ),
        actions: [
          IconButton(
            onPressed: _rename,
            icon: const Icon(Icons.edit),
            tooltip: 'Rename',
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecordingInfo(
              recording: widget.recording,
              formatDate: _formatDate,
              formatDuration: _formatDuration,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            PlaybackControls(
              sliderValue: sliderValue,
              total: total,
              position: _position,
              volume: _volume,
              filteredPath: _filteredPath,
              originalPath: widget.recording.path,
              formatDuration: _formatDuration,
              onPlay: _playRecording,
              onPause: _pausePlayback,
              onSeek: _seekPlayback,
              onVolumeChange: _setVolume,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            RecordingFilters(
              isApplying: _isApplying,
              onFilterApply: _applyFilter,
            ),

            const SizedBox(height: 16),

            if (_filteredPath != null)
              FilteredAudioInfo(
                filteredPath: _filteredPath!,
                onClear: () async {
                  try {
                    final file = File(_filteredPath!);
                    if (await file.exists()) await file.delete();
                  } catch (_) {}
                  setState(() => _filteredPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }
}
