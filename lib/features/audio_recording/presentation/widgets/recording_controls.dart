import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart' as record;
import 'package:waveform_flutter/waveform_flutter.dart' as waveform;
import 'package:dappunk/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import '../bloc/recording_state.dart';

class RecordingControls extends StatefulWidget {
  const RecordingControls({super.key});

  @override
  State<RecordingControls> createState() => _RecordingControlsState();
}

class _RecordingControlsState extends State<RecordingControls> {
  late final record.AudioRecorder _recorder;
  Stream<waveform.Amplitude>? _amplitudeStream;
  Timer? _pollingTimer;
  final StreamController<waveform.Amplitude> _amplitudeController =
      StreamController<waveform.Amplitude>.broadcast();

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _recorder = di<record.AudioRecorder>();
    _amplitudeStream = _amplitudeController.stream;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 100), (
      _,
    ) async {
      if (await _recorder.isRecording()) {
        final amp = await _recorder.getAmplitude();

        final normalized = (1.0 + (amp.current / 60.0)).clamp(0.0, 1.0);
        final current = normalized * 80.0;

        _amplitudeController.add(
          waveform.Amplitude(current: current, max: 80.0),
        );
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _amplitudeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordingBloc, RecordingState>(
      listener: (context, state) {
        if (state is RecordingInProgress && !state.isPaused) {
          if (_pollingTimer == null || !_pollingTimer!.isActive) {
            _startPolling();
          }
        } else {
          _stopPolling();
        }
      },
      builder: (context, state) {
        final isRecording = state is RecordingInProgress;
        final isPaused = isRecording && (state).isPaused;
        final duration = isRecording ? (state).duration : Duration.zero;

        if (isRecording &&
            !isPaused &&
            (_pollingTimer == null || !_pollingTimer!.isActive)) {
          _startPolling();
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isRecording
                        ? Colors.red.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isRecording
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (isRecording && !isPaused)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 100,
                          width: MediaQuery.of(context).size.width - 48,
                          child: waveform.AnimatedWaveList(
                            stream: _amplitudeStream!,
                            barBuilder: (animation, amplitude) {
                              return Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 4,
                                  height: amplitude.current,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: const EdgeInsets.only(right: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isRecording && !isPaused) const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRecording) ...[
                      IconButton(
                        onPressed: () {
                          if (isPaused) {
                            context.read<RecordingBloc>().add(
                              const ResumeRecordingEvent(),
                            );
                          } else {
                            context.read<RecordingBloc>().add(
                              const PauseRecordingEvent(),
                            );
                          }
                        },
                        icon: Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    ElevatedButton(
                      onPressed: () {
                        if (isRecording) {
                          context.read<RecordingBloc>().add(
                            const StopRecordingEvent(),
                          );
                        } else {
                          context.read<RecordingBloc>().add(
                            const StartRecordingEvent(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecording
                            ? Colors.red
                            : Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(24),
                        shape: const CircleBorder(),
                        elevation: 8,
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        size: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  isRecording
                      ? (isPaused ? 'Recording Paused' : 'Recording...')
                      : 'Tap to start recording',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
