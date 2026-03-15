import 'baby_entries.dart';

class AppData {
  final List<FeedingEntry> feedingEntries;
  final List<MedEntry> medEntries;
  final List<DiaperEntry> diaperEntries;
  final List<SolidFoodEntry> solidFoodEntries;
  final List<SleepEntry> sleepEntries;
  final List<GenericEntry> genericEntries;
  final List<CustomEntry> customEntries;

  // User goals
  final int waterGoalMl;
  final int foodGoalKcal;
  final int weightGoalKg;

  // User profile
  final String userName;
  final String userMotto;
  final String userAvatarPath;

  AppData({
    List<FeedingEntry>? feedingEntries,
    List<MedEntry>? medEntries,
    List<DiaperEntry>? diaperEntries,
    List<SolidFoodEntry>? solidFoodEntries,
    List<SleepEntry>? sleepEntries,
    List<GenericEntry>? genericEntries,
    List<CustomEntry>? customEntries,
    this.waterGoalMl = 2000,
    this.foodGoalKcal = 2200,
    this.weightGoalKg = 75,
    this.userName = '张新',
    this.userMotto = '口号凡是不轻松的时刻都是对生命的浪费！',
    this.userAvatarPath = '',
  })  : feedingEntries = feedingEntries ?? [],
        medEntries = medEntries ?? [],
        diaperEntries = diaperEntries ?? [],
        solidFoodEntries = solidFoodEntries ?? [],
        sleepEntries = sleepEntries ?? [],
        genericEntries = genericEntries ?? [],
        customEntries = customEntries ?? [];

  Map<String, dynamic> toJson() => {
        'feedingEntries': feedingEntries.map((e) => e.toJson()).toList(),
        'medEntries': medEntries.map((e) => e.toJson()).toList(),
        'diaperEntries': diaperEntries.map((e) => e.toJson()).toList(),
        'solidFoodEntries': solidFoodEntries.map((e) => e.toJson()).toList(),
        'sleepEntries': sleepEntries.map((e) => e.toJson()).toList(),
        'genericEntries': genericEntries.map((e) => e.toJson()).toList(),
        'customEntries': customEntries.map((e) => e.toJson()).toList(),
        'waterGoalMl': waterGoalMl,
        'foodGoalKcal': foodGoalKcal,
        'weightGoalKg': weightGoalKg,
        'userName': userName,
        'userMotto': userMotto,
        'userAvatarPath': userAvatarPath,
      };

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        feedingEntries: (json['feedingEntries'] as List? ?? [])
            .map((e) => FeedingEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        medEntries: (json['medEntries'] as List? ?? [])
            .map((e) => MedEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        diaperEntries: (json['diaperEntries'] as List? ?? [])
            .map((e) => DiaperEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        solidFoodEntries: (json['solidFoodEntries'] as List? ?? [])
            .map((e) => SolidFoodEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        sleepEntries: (json['sleepEntries'] as List? ?? [])
            .map((e) => SleepEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        genericEntries: (json['genericEntries'] as List? ?? [])
            .map((e) => GenericEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        customEntries: (json['customEntries'] as List? ?? [])
            .map((e) => CustomEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        waterGoalMl: (json['waterGoalMl'] as int?) ?? 2000,
        foodGoalKcal: (json['foodGoalKcal'] as int?) ?? 2200,
        weightGoalKg: (json['weightGoalKg'] as int?) ?? 75,
        userName: (json['userName'] as String?) ?? '张新',
        userMotto: (json['userMotto'] as String?) ?? '口号凡是不轻松的时刻都是对生命的浪费！',
        userAvatarPath: (json['userAvatarPath'] as String?) ?? '',
      );

  AppData copyWith({
    List<FeedingEntry>? feedingEntries,
    List<MedEntry>? medEntries,
    List<DiaperEntry>? diaperEntries,
    List<SolidFoodEntry>? solidFoodEntries,
    List<SleepEntry>? sleepEntries,
    List<GenericEntry>? genericEntries,
    List<CustomEntry>? customEntries,
    int? waterGoalMl,
    int? foodGoalKcal,
    int? weightGoalKg,
    String? userName,
    String? userMotto,
    String? userAvatarPath,
  }) =>
      AppData(
        feedingEntries: feedingEntries ?? this.feedingEntries,
        medEntries: medEntries ?? this.medEntries,
        diaperEntries: diaperEntries ?? this.diaperEntries,
        solidFoodEntries: solidFoodEntries ?? this.solidFoodEntries,
        sleepEntries: sleepEntries ?? this.sleepEntries,
        genericEntries: genericEntries ?? this.genericEntries,
        customEntries: customEntries ?? this.customEntries,
        waterGoalMl: waterGoalMl ?? this.waterGoalMl,
        foodGoalKcal: foodGoalKcal ?? this.foodGoalKcal,
        weightGoalKg: weightGoalKg ?? this.weightGoalKg,
        userName: userName ?? this.userName,
        userMotto: userMotto ?? this.userMotto,
        userAvatarPath: userAvatarPath ?? this.userAvatarPath,
      );

  AppData addFeeding(FeedingEntry e) =>
      copyWith(feedingEntries: [...feedingEntries, e]);
  AppData addMed(MedEntry e) => copyWith(medEntries: [...medEntries, e]);
  AppData addDiaper(DiaperEntry e) =>
      copyWith(diaperEntries: [...diaperEntries, e]);
  AppData addSolidFood(SolidFoodEntry e) =>
      copyWith(solidFoodEntries: [...solidFoodEntries, e]);
  AppData addSleep(SleepEntry e) =>
      copyWith(sleepEntries: [...sleepEntries, e]);
  AppData addGeneric(GenericEntry e) =>
      copyWith(genericEntries: [...genericEntries, e]);
  AppData addCustom(CustomEntry e) =>
      copyWith(customEntries: [...customEntries, e]);

  AppData removeFeeding(String id) => copyWith(
      feedingEntries: feedingEntries.where((e) => e.id != id).toList());
  AppData removeMed(String id) =>
      copyWith(medEntries: medEntries.where((e) => e.id != id).toList());
  AppData removeDiaper(String id) => copyWith(
      diaperEntries: diaperEntries.where((e) => e.id != id).toList());
  AppData removeSolidFood(String id) => copyWith(
      solidFoodEntries: solidFoodEntries.where((e) => e.id != id).toList());
  AppData removeSleep(String id) =>
      copyWith(sleepEntries: sleepEntries.where((e) => e.id != id).toList());
  AppData removeGeneric(String id) => copyWith(
      genericEntries: genericEntries.where((e) => e.id != id).toList());
  AppData removeCustom(String id) => copyWith(
      customEntries: customEntries.where((e) => e.id != id).toList());

  AppData updateSleep(SleepEntry e) => copyWith(
      sleepEntries: sleepEntries.map((s) => s.id == e.id ? e : s).toList());
  AppData updateGeneric(GenericEntry e) => copyWith(
      genericEntries:
          genericEntries.map((s) => s.id == e.id ? e : s).toList());
  AppData updateCustom(CustomEntry e) => copyWith(
      customEntries:
          customEntries.map((s) => s.id == e.id ? e : s).toList());
}
