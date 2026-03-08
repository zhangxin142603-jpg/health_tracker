import 'package:flutter/foundation.dart';
import '../models/app_data.dart';
import '../models/baby_entries.dart';
import '../services/app_storage.dart';

class AppProvider with ChangeNotifier {
  AppData _data = AppData();
  final AppStorage _storage = AppStorage();
  bool _isLoading = false;

  AppData get data => _data;
  bool get isLoading => _isLoading;

  List<FeedingEntry> get feedingEntries => _data.feedingEntries;
  List<MedEntry> get medEntries => _data.medEntries;
  List<DiaperEntry> get diaperEntries => _data.diaperEntries;
  List<SolidFoodEntry> get solidFoodEntries => _data.solidFoodEntries;
  List<SleepEntry> get sleepEntries => _data.sleepEntries;
  List<GenericEntry> get genericEntries => _data.genericEntries;
  List<CustomEntry> get customEntries => _data.customEntries;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _data = await _storage.loadData();
    } catch (e) {
      debugPrint('AppProvider _loadData error: $e');
      _data = AppData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    await _storage.saveData(_data);
  }

  Future<void> addFeeding(FeedingEntry e) async {
    _data = _data.addFeeding(e);
    notifyListeners();
    await _save();
  }

  Future<void> addMed(MedEntry e) async {
    _data = _data.addMed(e);
    notifyListeners();
    await _save();
  }

  Future<void> addDiaper(DiaperEntry e) async {
    _data = _data.addDiaper(e);
    notifyListeners();
    await _save();
  }

  Future<void> addSolidFood(SolidFoodEntry e) async {
    _data = _data.addSolidFood(e);
    notifyListeners();
    await _save();
  }

  Future<void> addSleep(SleepEntry e) async {
    _data = _data.addSleep(e);
    notifyListeners();
    await _save();
  }

  Future<void> addGeneric(GenericEntry e) async {
    _data = _data.addGeneric(e);
    notifyListeners();
    await _save();
  }

  Future<void> addCustom(CustomEntry e) async {
    _data = _data.addCustom(e);
    notifyListeners();
    await _save();
  }

  Future<void> updateSleep(SleepEntry e) async {
    _data = _data.updateSleep(e);
    notifyListeners();
    await _save();
  }

  Future<void> updateGeneric(GenericEntry e) async {
    _data = _data.updateGeneric(e);
    notifyListeners();
    await _save();
  }

  Future<void> updateCustom(CustomEntry e) async {
    _data = _data.updateCustom(e);
    notifyListeners();
    await _save();
  }

  Future<void> removeEntry(String type, String id) async {
    switch (type) {
      case 'feeding':
        _data = _data.removeFeeding(id);
        break;
      case 'med':
        _data = _data.removeMed(id);
        break;
      case 'diaper':
        _data = _data.removeDiaper(id);
        break;
      case 'solidFood':
        _data = _data.removeSolidFood(id);
        break;
      case 'sleep':
        _data = _data.removeSleep(id);
        break;
      case 'generic':
        _data = _data.removeGeneric(id);
        break;
      case 'custom':
        _data = _data.removeCustom(id);
        break;
    }
    notifyListeners();
    await _save();
  }
}
