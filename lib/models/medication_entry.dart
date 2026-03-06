import 'package:json_annotation/json_annotation.dart';

part 'medication_entry.g.dart';

@JsonSerializable()
class MedicationEntry {
  final String id;
  final String name;
  final String dosage;
  final DateTime timestamp;
  final String? notes; // optional notes

  MedicationEntry({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timestamp,
    this.notes,
  });

  factory MedicationEntry.fromJson(Map<String, dynamic> json) => _$MedicationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationEntryToJson(this);

  MedicationEntry copyWith({
    String? id,
    String? name,
    String? dosage,
    DateTime? timestamp,
    String? notes,
  }) {
    return MedicationEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}