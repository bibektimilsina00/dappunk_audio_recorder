import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/recording.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import '../bloc/recording_state.dart';

class RecordingsList extends StatelessWidget {
  const RecordingsList({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        if (state is RecordingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Recording> recordings = [];
        String? currentPlayingPath;
        bool isPlaying = false;

        if (state is RecordingsLoaded) {
          recordings = state.recordings;
          currentPlayingPath = state.currentPlayingPath;
          isPlaying = state.isPlaying;
        } else if (state is RecordingCompleted) {
          recordings = state.recordings;
        } else if (state is RecordingInProgress) {
          recordings = state.recordings;
        }

        if (recordings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_none, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No recordings yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start recording to see your files here',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recordings.length,
          itemBuilder: (context, index) {
            final recording =
                recordings[recordings.length - 1 - index]; // Reverse order
            final isCurrentlyPlaying = currentPlayingPath == recording.path;

            return Dismissible(
              key: Key(recording.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Recording'),
                    content: const Text(
                      'Are you sure you want to delete this recording?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                context.read<RecordingBloc>().add(
                  DeleteRecordingEvent(recording.id),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isCurrentlyPlaying ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isCurrentlyPlaying
                      ? BorderSide(color: Colors.blue.shade300, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCurrentlyPlaying
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCurrentlyPlaying && isPlaying
                          ? Icons.graphic_eq
                          : Icons.audiotrack,
                      color: isCurrentlyPlaying
                          ? Colors.blue.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                  title: Text(
                    'Recording ${recordings.length - index}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(recording.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duration: ${_formatDuration(recording.duration)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      if (isCurrentlyPlaying && isPlaying) {
                        context.read<RecordingBloc>().add(
                          const PausePlaybackEvent(),
                        );
                      } else {
                        context.read<RecordingBloc>().add(
                          PlayRecordingEvent(recording.path),
                        );
                      }
                    },
                    icon: Icon(
                      isCurrentlyPlaying && isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      size: 32,
                    ),
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
