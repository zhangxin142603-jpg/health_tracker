import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_data.dart';

class AppStorage {
  static const String _fileName = 'baby_app_data.json';
  static AppStorage? _instance;

  factory AppStorage() {
    _instance ??= AppStorage._internal();
    return _instance!;
  }

  AppStorage._internal();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<AppData> loadData() async {
    try {
      final f = await _file;
      if (!await f.exists()) return AppData();
      final json = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return AppData.fromJson(json);
    } catch (e) {
      debugPrint('AppStorage loadData error: $e');
      return AppData();
    }
  }

  Future<void> saveData(AppData data) async {
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('AppStorage saveData error: $e');
    }
  }

  Future<void> clearData() async {
    final f = await _file;
    if (await f.exists()) await f.delete();
  }
}
