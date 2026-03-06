import 'package:json_annotation/json_annotation.dart';
import 'water_entry.dart';
import 'medication_entry.dart';

part 'health_data.g.dart';

@JsonSerializable()
class HealthData {
  final List<WaterEntry> waterEntries;
  final List<MedicationEntry> medicationEntries;
  final int version;

  HealthData({
    List<WaterEntry>? waterEntries,
    List<MedicationEntry>? medicationEntries,
    this.version = 1,
  }) :
    waterEntries = waterEntries ?? [],
    medicationEntries = medicationEntries ?? [];

  factory HealthData.fromJson(Map<String, dynamic> json) => _$HealthDataFromJson(json);
  Map<String, dynamic> toJson() => _$HealthDataToJson(this);

  HealthData copyWith({
    List<WaterEntry>? waterEntries,
    List<MedicationEntry>? medicationEntries,
    int? version,
  }) {
    return HealthData(
      waterEntries: waterEntries ?? this.waterEntries,
      medicationEntries: medicationEntries ?? this.medicationEntries,
      version: version ?? this.version,
    );
  }

  // Helper methods
  HealthData addWaterEntry(WaterEntry entry) {
    return copyWith(
      waterEntries: List<WaterEntry>.from(waterEntries)..add(entry),
    );
  }

  HealthData addMedicationEntry(MedicationEntry entry) {
    return copyWith(
      medicationEntries: List<MedicationEntry>.from(medicationEntries)..add(entry),
    );
  }

  HealthData removeWaterEntry(String id) {
    return copyWith(
      waterEntries: waterEntries.where((entry) => entry.id != id).toList(),
    );
  }

  HealthData removeMedicationEntry(String id) {
    return copyWith(
      medicationEntries: medicationEntries.where((entry) => entry.id != id).toList(),
    );
  }
}