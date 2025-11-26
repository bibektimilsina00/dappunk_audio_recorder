import 'package:equatable/equatable.dart';

class Recording extends Equatable {
  final String id;
  final String path;
  final DateTime timestamp;
  final Duration duration;

  const Recording({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, path, timestamp, duration];
}
