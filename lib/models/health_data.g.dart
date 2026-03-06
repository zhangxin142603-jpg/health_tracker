// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthData _$HealthDataFromJson(Map<String, dynamic> json) => HealthData(
  waterEntries: (json['waterEntries'] as List<dynamic>?)
      ?.map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  medicationEntries: (json['medicationEntries'] as List<dynamic>?)
      ?.map((e) => MedicationEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  version: (json['version'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$HealthDataToJson(HealthData instance) =>
    <String, dynamic>{
      'waterEntries': instance.waterEntries,
      'medicationEntries': instance.medicationEntries,
      'version': instance.version,
    };
