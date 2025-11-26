import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/audio_failures.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../datasources/recording_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/recording_model.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingDataSource recordingDataSource;
  final LocalDataSource localDataSource;

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  Timer? _durationTimer;
  DateTime? _recordingStartTime;

  RecordingRepositoryImpl({
    required this.recordingDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> startRecording() async {
    try {
      // Request permission
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return Left(
          PermissionFailure(
            'Microphone permission permanently denied. Please enable it in settings.',
          ),
        );
      }

      if (!status.isGranted) {
        return Left(PermissionFailure('Microphone permission denied'));
      }

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/recording_$timestamp.m4a';

      // Start recording
      await recordingDataSource.startRecording(path);

      // Start duration timer
      _recordingStartTime = DateTime.now();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_recordingStartTime != null) {
          final duration = DateTime.now().difference(_recordingStartTime!);
          _durationController.add(duration);
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> stopRecording() async {
    try {
      // Stop timer
      _durationTimer?.cancel();
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!)
          : Duration.zero;
      _recordingStartTime = null;

      // Stop recording
      final path = await recordingDataSource.stopRecording();
      if (path == null) {
        return Left(RecordingFailure('Failed to stop recording'));
      }

      // Save metadata
      final recording = RecordingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: path,
        timestamp: DateTime.now(),
        duration: duration,
      );
      await localDataSource.saveRecording(recording);

      return Right(path);
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pauseRecording() async {
    try {
      await recordingDataSource.pauseRecording();
      _durationTimer?.cancel();
      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resumeRecording() async {
    try {
      await recordingDataSource.resumeRecording();

      // Resume timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_recordingStartTime != null) {
          final duration = DateTime.now().difference(_recordingStartTime!);
          _durationController.add(duration);
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recording>>> getRecordings() async {
    try {
      final recordings = await localDataSource.getRecordings();
      return Right(recordings);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecording(String id) async {
    try {
      // Get recording to delete file
      final recordings = await localDataSource.getRecordings();
      final recording = recordings.firstWhere((r) => r.id == id);

      // Delete file
      final file = File(recording.path);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete metadata
      await localDataSource.deleteRecording(id);

      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> playRecording(String path) async {
    try {
      await recordingDataSource.playAudio(path);
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pausePlayback() async {
    try {
      await recordingDataSource.pausePlayback();
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopPlayback() async {
    try {
      await recordingDataSource.stopPlayback();
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> seekTo(Duration position) async {
    try {
      await recordingDataSource.seekTo(position);
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    try {
      await recordingDataSource.setVolume(volume);
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure(e.toString()));
    }
  }

  @override
  Stream<Duration> get recordingDuration => _durationController.stream;

  @override
  Stream<Duration> get playbackPosition => recordingDataSource.positionStream;

  @override
  Stream<Duration?> get playbackDuration => recordingDataSource.durationStream;

  void dispose() {
    _durationTimer?.cancel();
    _durationController.close();
  }
}
