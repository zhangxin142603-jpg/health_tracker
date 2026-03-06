import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/health_data.dart';

class HealthStorage {
  static const String _fileName = 'health_data.json';
  static HealthStorage? _instance;

  factory HealthStorage() {
    _instance ??= HealthStorage._internal();
    return _instance!;
  }

  HealthStorage._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<HealthData> loadData() async {
    try {
      final file = await _localFile;

      // Check if file exists
      if (!await file.exists()) {
        // Return empty HealthData if file doesn't exist
        return HealthData();
      }

      // Read the file
      final contents = await file.readAsString();

      // Parse JSON and create HealthData
      final jsonMap = jsonDecode(contents) as Map<String, dynamic>;
      return HealthData.fromJson(jsonMap);
    } catch (e) {
      // If any error occurs, return empty HealthData
      print('Error loading health data: $e');
      return HealthData();
    }
  }

  Future<void> saveData(HealthData data) async {
    try {
      final file = await _localFile;

      // Convert HealthData to JSON
      final jsonData = data.toJson();
      final jsonString = jsonEncode(jsonData);

      // Write to file
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving health data: $e');
      rethrow;
    }
  }

  Future<void> clearData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing health data: $e');
      rethrow;
    }
  }
}