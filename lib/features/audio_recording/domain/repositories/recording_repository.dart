import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recording.dart';

abstract class RecordingRepository {
  // Recording operations
  Future<Either<Failure, void>> startRecording();
  Future<Either<Failure, String>> stopRecording();
  Future<Either<Failure, void>> pauseRecording();
  Future<Either<Failure, void>> resumeRecording();
  Future<Either<Failure, List<Recording>>> getRecordings();
  Future<Either<Failure, void>> deleteRecording(String id);
  Stream<Duration> get recordingDuration;

  // Playback operations
  Future<Either<Failure, void>> playRecording(String path);
  Future<Either<Failure, void>> pausePlayback();
  Future<Either<Failure, void>> stopPlayback();
  Future<Either<Failure, void>> seekTo(Duration position);
  Future<Either<Failure, void>> setVolume(double volume);
  Stream<Duration> get playbackPosition;
  Stream<Duration?> get playbackDuration;
}
