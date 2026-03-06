// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationEntry _$MedicationEntryFromJson(Map<String, dynamic> json) =>
    MedicationEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MedicationEntryToJson(MedicationEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dosage': instance.dosage,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
    };
