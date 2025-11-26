import '../../domain/entities/recording.dart';

class RecordingModel extends Recording {
  const RecordingModel({
    required super.id,
    required super.path,
    required super.timestamp,
    required super.duration,
  });

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'] as String,
      path: json['path'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: Duration(milliseconds: json['duration'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inMilliseconds,
    };
  }

  factory RecordingModel.fromEntity(Recording recording) {
    return RecordingModel(
      id: recording.id,
      path: recording.path,
      timestamp: recording.timestamp,
      duration: recording.duration,
    );
  }
}
