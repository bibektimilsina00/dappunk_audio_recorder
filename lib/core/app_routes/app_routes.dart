import 'package:go_router/go_router.dart';

import '../../features/audio_recording/presentation/pages/recording_detail_page.dart';
import '../../features/audio_recording/presentation/pages/recording_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
        path: AppRoutes.recordingPage,
        builder: (context, state) => const RecordingPage(),
    ),
    GoRoute(
      path: AppRoutes.recordingDetailPage,
      builder: (context, state) {
          final recording = state.extra as dynamic;
          return RecordingDetailPage(recording: recording);
      },
    ),
  ],
);


abstract class AppRoutes {
  static const String recordingPage = '/';
  static const String recordingDetailPage = '/recording';
}

