import 'package:record/record.dart' as record;
import 'package:just_audio/just_audio.dart';

/// Data source for audio recording and playback operations
abstract class RecordingDataSource {
  // Recording operations
  Future<void> startRecording(String path);
  Future<String?> stopRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<bool> isRecording();
  Future<bool> isPaused();
  record.AudioRecorder get recorder;

  // Playback operations
  Future<void> playAudio(String path);
  Future<void> pausePlayback();
  Future<void> stopPlayback();
  Future<void> seekTo(Duration position);
  Future<void> setVolume(double volume);
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  Future<void> dispose();
}

class RecordingDataSourceImpl implements RecordingDataSource {
  final record.AudioRecorder _recorder;
  final AudioPlayer player;

  RecordingDataSourceImpl({
    required record.AudioRecorder recorder,
    required this.player,
  }) : _recorder = recorder;

  @override
  Future<void> startRecording(String path) async {
    final hasPermission = await _recorder.hasPermission();
    if (hasPermission) {
      try {
        await _recorder.start(
          const record.RecordConfig(
            encoder: record.AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        print('Recording started: $path');
      } catch (e) {
        print('Failed to start recording: $e');
        rethrow;
      }
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  @override
  Future<String?> stopRecording() async {
    final result = await _recorder.stop();

    print('Recording stopped: $result');
    return result;
  }

  @override
  Future<void> pauseRecording() async {
    await _recorder.pause();
  }

  @override
  Future<void> resumeRecording() async {
    await _recorder.resume();
  }

  @override
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  @override
  Future<bool> isPaused() async {
    return await _recorder.isPaused();
  }

  // Provide access to the recorder for the UI to display waveforms
  @override
  record.AudioRecorder get recorder => _recorder;

  // Playback operations
  @override
  Future<void> playAudio(String path) async {
    await player.setFilePath(path);
    await player.play();
  }

  @override
  Future<void> pausePlayback() async {
    await player.pause();
  }

  @override
  Future<void> stopPlayback() async {
    await player.stop();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await player.seek(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    await player.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Stream<Duration> get positionStream => player.positionStream;

  @override
  Stream<Duration?> get durationStream => player.durationStream;

  @override
  Future<void> dispose() async {
    _recorder.dispose();
    await player.dispose();
  }
}
