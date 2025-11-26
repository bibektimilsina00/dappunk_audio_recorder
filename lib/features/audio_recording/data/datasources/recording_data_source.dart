import 'package:record/record.dart';
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
  final AudioRecorder recorder;
  final AudioPlayer player;

  RecordingDataSourceImpl({required this.recorder, required this.player});

  // Recording operations
  @override
  Future<void> startRecording(String path) async {
    if (await recorder.hasPermission()) {
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  @override
  Future<String?> stopRecording() async {
    return await recorder.stop();
  }

  @override
  Future<void> pauseRecording() async {
    await recorder.pause();
  }

  @override
  Future<void> resumeRecording() async {
    await recorder.resume();
  }

  @override
  Future<bool> isRecording() async {
    return await recorder.isRecording();
  }

  @override
  Future<bool> isPaused() async {
    return await recorder.isPaused();
  }

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
    await recorder.dispose();
    await player.dispose();
  }
}
