import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recording_model.dart';

abstract class LocalDataSource {
  Future<void> saveRecording(RecordingModel recording);
  Future<List<RecordingModel>> getRecordings();
  Future<void> deleteRecording(String id);
  Future<void> renameRecording(String id, String newName);
  Future<void> clearAll();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _recordingsKey = 'recordings';

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveRecording(RecordingModel recording) async {
    final recordings = await getRecordings();
    recordings.add(recording);

    final jsonList = recordings.map((r) => r.toJson()).toList();
    await sharedPreferences.setString(_recordingsKey, json.encode(jsonList));
  }

  @override
  Future<List<RecordingModel>> getRecordings() async {
    final jsonString = sharedPreferences.getString(_recordingsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => RecordingModel.fromJson(json)).toList();
  }

  @override
  Future<void> deleteRecording(String id) async {
    final recordings = await getRecordings();
    recordings.removeWhere((r) => r.id == id);

    final jsonList = recordings.map((r) => r.toJson()).toList();
    await sharedPreferences.setString(_recordingsKey, json.encode(jsonList));
  }

  @override
  Future<void> renameRecording(String id, String newName) async {
    final recordings = await getRecordings();
    for (var r in recordings) {
      if (r.id == id) {
        final updated = RecordingModel(
          id: r.id,
          path: r.path,
          name: newName,
          timestamp: r.timestamp,
          duration: r.duration,
        );
        final idx = recordings.indexOf(r);
        recordings[idx] = updated;
        break;
      }
    }

    final jsonList = recordings.map((r) => r.toJson()).toList();
    await sharedPreferences.setString(_recordingsKey, json.encode(jsonList));
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.remove(_recordingsKey);
  }
}
