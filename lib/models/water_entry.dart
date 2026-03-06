import 'package:json_annotation/json_annotation.dart';

part 'water_entry.g.dart';

@JsonSerializable()
class WaterEntry {
  final String id;
  final int amount; // in milliliters (ml)
  final DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.amount,
    required this.timestamp,
  });

  factory WaterEntry.fromJson(Map<String, dynamic> json) => _$WaterEntryFromJson(json);
  Map<String, dynamic> toJson() => _$WaterEntryToJson(this);

  WaterEntry copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}