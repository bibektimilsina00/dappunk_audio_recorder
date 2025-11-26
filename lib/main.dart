import 'package:dappunk/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/app_routes/app_routes.dart';
import 'injection_container.dart' as di;
import 'features/audio_recording/presentation/bloc/recording_bloc.dart';
import 'features/audio_recording/presentation/bloc/recording_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              di.di<RecordingBloc>()..add(const LoadRecordingsEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'DapPunk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
