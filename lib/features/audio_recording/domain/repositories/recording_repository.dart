import 'package:dartz/dartz.dart';
import 'package:record/record.dart' as record;
import '../../../../core/error/failures.dart';
import '../entities/recording.dart';

abstract class RecordingRepository {
  Future<Either<Failure, void>> startRecording();
  Future<Either<Failure, String>> stopRecording();
  Future<Either<Failure, void>> pauseRecording();
  Future<Either<Failure, void>> resumeRecording();
  Future<Either<Failure, List<Recording>>> getRecordings();
  Future<Either<Failure, void>> deleteRecording(String id);
  Future<Either<Failure, void>> renameRecording(String id, String newName);

  Stream<Duration> get recordingDuration;

  /// Recorder for UI waveform rendering during recording
  record.AudioRecorder get recorder;

  Future<Either<Failure, void>> playRecording(String path);
  Future<Either<Failure, void>> pausePlayback();
  Future<Either<Failure, void>> stopPlayback();
  Future<Either<Failure, void>> seekTo(Duration position);
  Future<Either<Failure, void>> setVolume(double volume);
  Stream<Duration> get playbackPosition;
  Stream<Duration?> get playbackDuration;
}
