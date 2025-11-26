import 'package:equatable/equatable.dart';
import '../../domain/entities/recording.dart';

abstract class RecordingState extends Equatable {
  const RecordingState();

  @override
  List<Object?> get props => [];
}

class RecordingInitial extends RecordingState {
  const RecordingInitial();
}

class RecordingLoading extends RecordingState {
  const RecordingLoading();
}

class RecordingInProgress extends RecordingState {
  final Duration duration;
  final bool isPaused;
  final List<Recording> recordings;

  const RecordingInProgress({
    required this.duration,
    this.isPaused = false,
    this.recordings = const [],
  });

  @override
  List<Object?> get props => [duration, isPaused, recordings];
}

class RecordingCompleted extends RecordingState {
  final String path;
  final List<Recording> recordings;

  const RecordingCompleted({required this.path, required this.recordings});

  @override
  List<Object?> get props => [path, recordings];
}

class RecordingsLoaded extends RecordingState {
  final List<Recording> recordings;
  final String? currentPlayingPath;
  final bool isPlaying;

  const RecordingsLoaded({
    required this.recordings,
    this.currentPlayingPath,
    this.isPlaying = false,
  });

  RecordingsLoaded copyWith({
    List<Recording>? recordings,
    String? currentPlayingPath,
    bool? isPlaying,
  }) {
    return RecordingsLoaded(
      recordings: recordings ?? this.recordings,
      currentPlayingPath: currentPlayingPath ?? this.currentPlayingPath,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [recordings, currentPlayingPath, isPlaying];
}

class RecordingError extends RecordingState {
  final String message;

  const RecordingError(this.message);

  @override
  List<Object?> get props => [message];
}
