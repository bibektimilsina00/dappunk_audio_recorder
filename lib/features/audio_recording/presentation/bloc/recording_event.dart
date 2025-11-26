import 'package:equatable/equatable.dart';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class StartRecordingEvent extends RecordingEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends RecordingEvent {
  const StopRecordingEvent();
}

class PauseRecordingEvent extends RecordingEvent {
  const PauseRecordingEvent();
}

class ResumeRecordingEvent extends RecordingEvent {
  const ResumeRecordingEvent();
}

class LoadRecordingsEvent extends RecordingEvent {
  const LoadRecordingsEvent();
}

class DeleteRecordingEvent extends RecordingEvent {
  final String id;

  const DeleteRecordingEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RenameRecordingEvent extends RecordingEvent {
  final String id;
  final String newName;

  const RenameRecordingEvent(this.id, this.newName);

  @override
  List<Object?> get props => [id, newName];
}

class PlayRecordingEvent extends RecordingEvent {
  final String path;

  const PlayRecordingEvent(this.path);

  @override
  List<Object?> get props => [path];
}

class PausePlaybackEvent extends RecordingEvent {
  const PausePlaybackEvent();
}

class StopPlaybackEvent extends RecordingEvent {
  const StopPlaybackEvent();
}

class SeekPlaybackEvent extends RecordingEvent {
  final Duration position;

  const SeekPlaybackEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdateRecordingDurationEvent extends RecordingEvent {
  final Duration duration;

  const UpdateRecordingDurationEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class SetPlaybackVolumeEvent extends RecordingEvent {
  final double volume;

  const SetPlaybackVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ApplyFilterEvent extends RecordingEvent {
  final String id;
  final String path;
  final String outputPath;
  final String filterName;

  const ApplyFilterEvent({
    required this.id,
    required this.path,
    required this.outputPath,
    required this.filterName,
  });

  @override
  List<Object?> get props => [id, path, outputPath, filterName];
}

 
