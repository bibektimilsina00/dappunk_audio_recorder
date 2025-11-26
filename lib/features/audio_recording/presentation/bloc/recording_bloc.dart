import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
import '../../domain/usecases/get_recordings.dart';
import '../../domain/usecases/play_recording.dart';
import '../../domain/usecases/rename_recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../domain/entities/recording.dart';
import 'recording_event.dart';
import 'recording_state.dart';
import 'package:dappunk/features/audio_filter/domain/usecases/apply_filter.dart';
import 'package:dappunk/features/audio_filter/domain/entities/filter_type.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecording startRecording;
  final StopRecording stopRecording;
  final GetRecordings getRecordings;
  final PlayRecording playRecording;
  final RenameRecording? renameRecording;
  final ApplyFilter? applyFilter;
  final RecordingRepository repository;

  StreamSubscription? _durationSubscription;

  RecordingBloc({
    required this.startRecording,
    required this.stopRecording,
    required this.getRecordings,
    required this.playRecording,
    this.renameRecording,
    this.applyFilter,
    required this.repository,
  }) : super(const RecordingInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<LoadRecordingsEvent>(_onLoadRecordings);
    on<DeleteRecordingEvent>(_onDeleteRecording);
    on<RenameRecordingEvent>(_onRenameRecording);
    on<ApplyFilterEvent>(_onApplyFilter);

    on<PlayRecordingEvent>(_onPlayRecording);
    on<PausePlaybackEvent>(_onPausePlayback);
    on<StopPlaybackEvent>(_onStopPlayback);
    on<SeekPlaybackEvent>(_onSeekPlayback);
    on<SetPlaybackVolumeEvent>(_onSetPlaybackVolume);
    on<UpdateRecordingDurationEvent>(_onUpdateRecordingDuration);
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    List<Recording> currentRecordings = [];
    if (state is RecordingsLoaded) {
      currentRecordings = (state as RecordingsLoaded).recordings;
    } else if (state is RecordingCompleted) {
      currentRecordings = (state as RecordingCompleted).recordings;
    }

    final result = await startRecording(NoParams());

    result.fold((failure) => emit(RecordingError(failure.toString())), (_) {
      emit(
        RecordingInProgress(
          duration: Duration.zero,
          recordings: currentRecordings,
        ),
      );

      // Listen to duration updates
      _durationSubscription = repository.recordingDuration.listen((duration) {
        add(UpdateRecordingDurationEvent(duration));
      });
    });
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    _durationSubscription?.cancel();

    final result = await stopRecording(NoParams());

    await result.fold(
      (failure) async => emit(RecordingError(failure.toString())),
      (path) async {
        final recordingsResult = await getRecordings(NoParams());
        recordingsResult.fold(
          (failure) => emit(RecordingError(failure.toString())),
          (recordings) =>
              emit(RecordingCompleted(path: path, recordings: recordings)),
        );
      },
    );
  }

  Future<void> _onPauseRecording(
    PauseRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      final result = await repository.pauseRecording();

      result.fold(
        (failure) => emit(RecordingError(failure.toString())),
        (_) => emit(
          RecordingInProgress(
            duration: currentState.duration,
            isPaused: true,
            recordings: currentState.recordings,
          ),
        ),
      );
    }
  }

  Future<void> _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      final result = await repository.resumeRecording();

      result.fold(
        (failure) => emit(RecordingError(failure.toString())),
        (_) => emit(
          RecordingInProgress(
            duration: currentState.duration,
            isPaused: false,
            recordings: currentState.recordings,
          ),
        ),
      );
    }
  }

  Future<void> _onLoadRecordings(
    LoadRecordingsEvent event,
    Emitter<RecordingState> emit,
  ) async {
    emit(const RecordingLoading());

    final result = await getRecordings(NoParams());

    result.fold(
      (failure) => emit(RecordingError(failure.toString())),
      (recordings) => emit(RecordingsLoaded(recordings: recordings)),
    );
  }

  Future<void> _onDeleteRecording(
    DeleteRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await repository.deleteRecording(event.id);

    result.fold((failure) => emit(RecordingError(failure.toString())), (_) {
      // Reload recordings
      add(const LoadRecordingsEvent());
    });
  }

  Future<void> _onRenameRecording(
    RenameRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    if (renameRecording == null) return;
    final result = await renameRecording!(
      RenameRecordingParams(id: event.id, newName: event.newName),
    );

    result.fold(
      (failure) => emit(RecordingError(failure.toString())),
      (_) => add(const LoadRecordingsEvent()),
    );
  }

  Future<void> _onApplyFilter(
    ApplyFilterEvent event,
    Emitter<RecordingState> emit,
  ) async {
    if (applyFilter == null) return;

    // Map filterName to FilterType
    FilterType? ftype;
    switch (event.filterName.toLowerCase()) {
      case 'chipmunk':
        ftype = FilterType.chipmunk;
        break;
      case 'deep':
      case 'deep voice':
        ftype = FilterType.deep;
        break;
      case 'telephone':
        ftype = FilterType.telephone;
        break;
      case 'underwater':
        ftype = FilterType.underwater;
        break;
      default:
        ftype = FilterType.chipmunk;
    }

    final result = await applyFilter!(
      ApplyFilterParams(
        inputPath: event.path,
        outputPath: event.outputPath,
        type: ftype,
      ),
    );

    result.fold((failure) => emit(RecordingError(failure.toString())), (
      filteredPath,
    ) async {
      add(PlayRecordingEvent(filteredPath));
    });
  }

  Future<void> _onPlayRecording(
    PlayRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await playRecording(PlayRecordingParams(path: event.path));

    result.fold((failure) => emit(RecordingError(failure.toString())), (_) {
      if (state is RecordingsLoaded) {
        final currentState = state as RecordingsLoaded;
        emit(
          currentState.copyWith(
            currentPlayingPath: event.path,
            isPlaying: true,
          ),
        );
      }
    });
  }

  Future<void> _onPausePlayback(
    PausePlaybackEvent event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await repository.pausePlayback();

    result.fold((failure) => emit(RecordingError(failure.toString())), (_) {
      if (state is RecordingsLoaded) {
        final currentState = state as RecordingsLoaded;
        emit(currentState.copyWith(isPlaying: false));
      }
    });
  }

  Future<void> _onStopPlayback(
    StopPlaybackEvent event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await repository.stopPlayback();

    result.fold((failure) => emit(RecordingError(failure.toString())), (_) {
      if (state is RecordingsLoaded) {
        final currentState = state as RecordingsLoaded;
        emit(currentState.copyWith(currentPlayingPath: null, isPlaying: false));
      }
    });
  }

  Future<void> _onSeekPlayback(
    SeekPlaybackEvent event,
    Emitter<RecordingState> emit,
  ) async {
    await repository.seekTo(event.position);
  }

  Future<void> _onSetPlaybackVolume(
    SetPlaybackVolumeEvent event,
    Emitter<RecordingState> emit,
  ) async {
    await repository.setVolume(event.volume);
  }

  void _onUpdateRecordingDuration(
    UpdateRecordingDurationEvent event,
    Emitter<RecordingState> emit,
  ) {
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      emit(
        RecordingInProgress(
          duration: event.duration,
          isPaused: currentState.isPaused,
          recordings: currentState.recordings,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _durationSubscription?.cancel();
    return super.close();
  }
}
