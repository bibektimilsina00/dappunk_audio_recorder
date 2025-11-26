import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'injection_container.dart' as di;
import 'features/audio_recording/presentation/bloc/recording_bloc.dart';
import 'features/audio_recording/presentation/bloc/recording_event.dart';
import 'features/audio_recording/presentation/pages/recording_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DapPunk - Voice Recorder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (context) =>
            di.di<RecordingBloc>()..add(const LoadRecordingsEvent()),
        child: const RecordingPage(),
      ),
    ),
  ],
);
