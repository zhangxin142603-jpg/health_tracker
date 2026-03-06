// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterEntry _$WaterEntryFromJson(Map<String, dynamic> json) => WaterEntry(
  id: json['id'] as String,
  amount: (json['amount'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$WaterEntryToJson(WaterEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
    };
