import 'package:get_it/get_it.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

// Audio Recording Feature
import 'features/audio_recording/data/datasources/recording_data_source.dart';

// Audio Filter Feature
import 'features/audio_filter/data/datasources/filter_data_source.dart';

final di = GetIt.instance;

Future<void> init() async {
  //! Features - Audio Recording

  // Use cases
  // TODO: Register use cases when repositories are implemented
  // di.registerLazySingleton(() => StartRecording(di()));
  // di.registerLazySingleton(() => StopRecording(di()));
  // di.registerLazySingleton(() => GetRecordings(di()));
  // di.registerLazySingleton(() => PlayRecording(di()));

  // Repository
  // TODO: Register repository implementation

  // Data sources
  di.registerLazySingleton<RecordingDataSource>(
    () => RecordingDataSourceImpl(recorder: di(), player: di()),
  );

  //! Features - Audio Filter

  // Use cases
  // TODO: Register use cases when repositories are implemented
  // di.registerLazySingleton(() => ApplyAudioFilter(di()));

  // Repository
  // TODO: Register repository implementation

  // Data sources
  di.registerLazySingleton<FilterDataSource>(() => FilterDataSourceImpl());

  //! Core
  // TODO: Add core dependencies

  //! External
  di.registerLazySingleton(() => AudioRecorder());
  di.registerLazySingleton(() => AudioPlayer());
}
