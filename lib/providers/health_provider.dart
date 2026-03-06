import 'package:flutter/foundation.dart';
import '../models/health_data.dart';
import '../models/water_entry.dart';
import '../models/medication_entry.dart';
import '../services/health_storage.dart';

class HealthProvider with ChangeNotifier {
  late HealthData _healthData;
  final HealthStorage _storage = HealthStorage();
  bool _isLoading = false;

  HealthData get healthData => _healthData;
  bool get isLoading => _isLoading;

  List<WaterEntry> get waterEntries => _healthData.waterEntries;
  List<MedicationEntry> get medicationEntries => _healthData.medicationEntries;

  HealthProvider() {
    _healthData = HealthData();
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthData = await _storage.loadData();
    } catch (e) {
      print('Error loading data: $e');
      _healthData = HealthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      await _storage.saveData(_healthData);
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  Future<void> addWaterEntry(int amount) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now(),
    );

    _healthData = _healthData.addWaterEntry(entry);
    notifyListeners();
    await _saveData();
  }

  Future<void> addMedicationEntry(String name, String dosage, {String? notes}) async {
    final entry = MedicationEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      dosage: dosage,
      timestamp: DateTime.now(),
      notes: notes,
    );

    _healthData = _healthData.addMedicationEntry(entry);
    notifyListeners();
    await _saveData();
  }

  Future<void> removeWaterEntry(String id) async {
    _healthData = _healthData.removeWaterEntry(id);
    notifyListeners();
    await _saveData();
  }

  Future<void> removeMedicationEntry(String id) async {
    _healthData = _healthData.removeMedicationEntry(id);
    notifyListeners();
    await _saveData();
  }

  Future<void> clearAllData() async {
    await _storage.clearData();
    _healthData = HealthData();
    notifyListeners();
  }

  // Statistics
  int getTodayWaterTotal() {
    final today = DateTime.now();
    return waterEntries
        .where((entry) =>
          entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day)
        .fold(0, (total, entry) => total + entry.amount);
  }

  List<MedicationEntry> getTodayMedications() {
    final today = DateTime.now();
    return medicationEntries
        .where((entry) =>
          entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day)
        .toList();
  }
}