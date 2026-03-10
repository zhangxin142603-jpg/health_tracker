class FeedingEntry {
  final String id;
  final DateTime timestamp;
  final int amountMl;
  final String milkSource; // '喂水' | '喂食' | '喂食+喂水'
  final int? foodAmountKcal; // 食量（千卡），仅当 milkSource 包含喂食时有效
  final int? waterAmountMl;  // 水量（毫升），仅当 milkSource 包含喂水时有效
  final String? notes;

  const FeedingEntry({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.milkSource = '喂水',
    this.foodAmountKcal,
    this.waterAmountMl,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
        'milkSource': milkSource,
        'foodAmountKcal': foodAmountKcal,
        'waterAmountMl': waterAmountMl,
        'notes': notes,
      };

  factory FeedingEntry.fromJson(Map<String, dynamic> json) => FeedingEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        amountMl: (json['amountMl'] as num).toInt(),
        milkSource: json['milkSource'] as String? ?? '喂水',
        foodAmountKcal: (json['foodAmountKcal'] as num?)?.toInt(),
        waterAmountMl: (json['waterAmountMl'] as num?)?.toInt(),
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
        return '解大';
      case 'both':
        return '解大+解小';
      default:
        return '解小';
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

/// type: '睡眠' | '锻炼' | '觉察' | '疗愈' | '真我'
class GenericEntry {
  final String id;
  final String type;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;

  const GenericEntry({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'notes': notes,
      };

  factory GenericEntry.fromJson(Map<String, dynamic> json) => GenericEntry(
        id: json['id'] as String,
        type: json['type'] as String? ?? '自定义',
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        notes: json['notes'] as String?,
      );
}

class CustomEntry {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String eventName;
  final String? notes;

  const CustomEntry({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.eventName,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'eventName': eventName,
        'notes': notes,
      };

  factory CustomEntry.fromJson(Map<String, dynamic> json) => CustomEntry(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        eventName: json['eventName'] as String? ?? '',
        notes: json['notes'] as String?,
      );
}
