class FeedingEntry {
  final String id;
  final DateTime timestamp;
  final int amountMl;
  final String? notes;

  const FeedingEntry({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
        'notes': notes,
      };

  factory FeedingEntry.fromJson(Map<String, dynamic> json) => FeedingEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        amountMl: (json['amountMl'] as num).toInt(),
        notes: json['notes'] as String?,
      );
}

class MedEntry {
  final String id;
  final DateTime timestamp;
  final List<String> medicines;
  final String? notes;

  const MedEntry({
    required this.id,
    required this.timestamp,
    required this.medicines,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'medicines': medicines,
        'notes': notes,
      };

  factory MedEntry.fromJson(Map<String, dynamic> json) => MedEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        medicines: List<String>.from(json['medicines'] as List? ?? []),
        notes: json['notes'] as String?,
      );
}

/// diaperType: 'wet' | 'poop' | 'both'
class DiaperEntry {
  final String id;
  final DateTime timestamp;
  final String diaperType;
  final String? urineColor;
  final List<String> symptoms;
  final String? notes;

  const DiaperEntry({
    required this.id,
    required this.timestamp,
    required this.diaperType,
    this.urineColor,
    required this.symptoms,
    this.notes,
  });

  String get typeLabel {
    switch (diaperType) {
      case 'poop':
        return '大便';
      case 'both':
        return '大便+小便';
      default:
        return '小便';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'diaperType': diaperType,
        'urineColor': urineColor,
        'symptoms': symptoms,
        'notes': notes,
      };

  factory DiaperEntry.fromJson(Map<String, dynamic> json) => DiaperEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        diaperType: json['diaperType'] as String? ?? 'wet',
        urineColor: json['urineColor'] as String?,
        symptoms: List<String>.from(json['symptoms'] as List? ?? []),
        notes: json['notes'] as String?,
      );
}

/// unit: '数量' | 'mL'
class SolidFoodEntry {
  final String id;
  final DateTime timestamp;
  final bool ate;
  final double? amount;
  final String unit;
  final List<String> foodTypes;
  final String? texture;
  final String? notes;

  const SolidFoodEntry({
    required this.id,
    required this.timestamp,
    required this.ate,
    this.amount,
    required this.unit,
    required this.foodTypes,
    this.texture,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'ate': ate,
        'amount': amount,
        'unit': unit,
        'foodTypes': foodTypes,
        'texture': texture,
        'notes': notes,
      };

  factory SolidFoodEntry.fromJson(Map<String, dynamic> json) => SolidFoodEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        ate: json['ate'] as bool? ?? true,
        amount: (json['amount'] as num?)?.toDouble(),
        unit: json['unit'] as String? ?? '数量',
        foodTypes: List<String>.from(json['foodTypes'] as List? ?? []),
        texture: json['texture'] as String?,
        notes: json['notes'] as String?,
      );
}

class SleepEntry {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;

  const SleepEntry({
    required this.id,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  String get durationText {
    if (endTime == null) return '进行中';
    final diff = endTime!.difference(startTime);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return m > 0 ? '$h小时$m分' : '$h小时';
    return '$m分';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'notes': notes,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        notes: json['notes'] as String?,
      );
}
