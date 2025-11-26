import 'package:equatable/equatable.dart';

class Recording extends Equatable {
  final String id;
  final String path;
  final String name;
  final DateTime timestamp;
  final Duration duration;

  const Recording({
    required this.id,
    required this.path,
    required this.name,
    required this.timestamp,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, path, name, timestamp, duration];
}
