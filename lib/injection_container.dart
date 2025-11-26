import 'package:get_it/get_it.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Audio Recording Feature
import 'features/audio_recording/data/datasources/recording_data_source.dart';
import 'features/audio_recording/data/datasources/local_data_source.dart';
import 'features/audio_recording/data/repositories/recording_repository_impl.dart';
import 'features/audio_recording/domain/repositories/recording_repository.dart';
import 'features/audio_recording/domain/usecases/start_recording.dart';
import 'features/audio_recording/domain/usecases/stop_recording.dart';
import 'features/audio_recording/domain/usecases/get_recordings.dart';
import 'features/audio_recording/domain/usecases/play_recording.dart';
import 'features/audio_recording/presentation/bloc/recording_bloc.dart';

// Audio Filter Feature
import 'features/audio_filter/data/datasources/filter_data_source.dart';

final di = GetIt.instance;

Future<void> init() async {
  //! Features - Audio Recording

  // BLoC
  di.registerFactory(
    () => RecordingBloc(
      startRecording: di(),
      stopRecording: di(),
      getRecordings: di(),
      playRecording: di(),
      repository: di(),
    ),
  );

  // Use cases
  di.registerLazySingleton(() => StartRecording(di()));
  di.registerLazySingleton(() => StopRecording(di()));
  di.registerLazySingleton(() => GetRecordings(di()));
  di.registerLazySingleton(() => PlayRecording(di()));

  // Repository
  di.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(
      recordingDataSource: di(),
      localDataSource: di(),
    ),
  );

  // Data sources
  di.registerLazySingleton<RecordingDataSource>(
    () => RecordingDataSourceImpl(recorder: di(), player: di()),
  );

  di.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: di()),
  );

  //! Features - Audio Filter

  // Data sources
  di.registerLazySingleton<FilterDataSource>(() => FilterDataSourceImpl());

  //! Core
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerLazySingleton(() => sharedPreferences);

  //! External
  di.registerLazySingleton(() => AudioRecorder());
  di.registerLazySingleton(() => AudioPlayer());
}
