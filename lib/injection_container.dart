import 'package:get_it/get_it.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

// Audio Recording Feature
import 'features/audio_recording/data/datasources/recording_data_source.dart';

// Audio Filter Feature
import 'features/audio_filter/data/datasources/filter_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Audio Recording

  // Use cases
  // TODO: Register use cases when repositories are implemented
  // sl.registerLazySingleton(() => StartRecording(sl()));
  // sl.registerLazySingleton(() => StopRecording(sl()));
  // sl.registerLazySingleton(() => GetRecordings(sl()));
  // sl.registerLazySingleton(() => PlayRecording(sl()));

  // Repository
  // TODO: Register repository implementation

  // Data sources
  sl.registerLazySingleton<RecordingDataSource>(
    () => RecordingDataSourceImpl(recorder: sl(), player: sl()),
  );

  //! Features - Audio Filter

  // Use cases
  // TODO: Register use cases when repositories are implemented
  // sl.registerLazySingleton(() => ApplyAudioFilter(sl()));

  // Repository
  // TODO: Register repository implementation

  // Data sources
  sl.registerLazySingleton<FilterDataSource>(() => FilterDataSourceImpl());

  //! Core
  // TODO: Add core dependencies

  //! External
  sl.registerLazySingleton(() => AudioRecorder());
  sl.registerLazySingleton(() => AudioPlayer());
}
