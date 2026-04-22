import 'package:flutter/material.dart';
import 'strings.dart';

/// 简化版本地化类
/// 提供字符串访问接口，未来可扩展为多语言支持
class AppLocalizations {
  const AppLocalizations();

  // ==================== 应用通用 ====================
  String get appTitle => AppStrings.appTitle;
  String get all => AppStrings.all;
  String get inviteFriends => AppStrings.inviteFriends;
  String get noRecords => AppStrings.noRecords;
  String get clickToAdd => AppStrings.clickToAdd;
  String get todayNoRecords => AppStrings.todayNoRecords;
  String get today => AppStrings.today;
  String get todayLabel => AppStrings.todayLabel;
  String get pastLabel => AppStrings.pastLabel;
  String get me => AppStrings.me;
  String get todayRecordsSummary => AppStrings.todayRecordsSummary;
  String get collapseDetails => AppStrings.collapseDetails;
  String get expandDetails => AppStrings.expandDetails;
  String get feedingSummaryLabel => AppStrings.feedingSummaryLabel;
  String get diaperSummaryLabel => AppStrings.diaperSummaryLabel;
  String get sleepSummaryLabel => AppStrings.sleepSummaryLabel;
  String totalMlLabel(int ml) => AppStrings.totalMlLabel.replaceAll('{mL}', ml.toString());
  String timesLabel(int count) => AppStrings.timesLabel.replaceAll('{count}', count.toString());

  // ==================== 时间描述 ====================
  String get justNow => AppStrings.justNow;
  String minutesAgo(int minutes) => AppStrings.getMinutesAgo(minutes);
  String hoursAgo(int hours) => AppStrings.getHoursAgo(hours);
  String hoursMinutesAgo(int hours, int minutes) =>
      AppStrings.getHoursMinutesAgo(hours, minutes);
  String get inProgress => AppStrings.inProgress;
  String sleepEndLabel(String time) => AppStrings.sleepEndLabel.replaceAll('{time}', time);
  String totalMlKcalLabel(int ml, int kcal) => AppStrings.totalMlKcalLabel.replaceAll('{mL}', ml.toString()).replaceAll('{kcal}', kcal.toString());
  String hourMinuteLabel(int hours, int minutes) => AppStrings.hourMinuteLabel.replaceAll('{hours}', hours.toString()).replaceAll('{minutes}', minutes.toString());
  String minuteLabel(int minutes) => AppStrings.minuteLabel.replaceAll('{minutes}', minutes.toString());
  String hourLabel(int hours) => AppStrings.hourLabel.replaceAll('{hours}', hours.toString());
  String totalHourMinuteLabel(int hours, int minutes) => AppStrings.totalHourMinuteLabel.replaceAll('{hours}', hours.toString()).replaceAll('{minutes}', minutes.toString());

  // ==================== 喂养模块 ====================
  String get feeding => AppStrings.feeding;
  String get feedingRecord => AppStrings.feedingRecord;
  String feedingCount(int count) => AppStrings.getFeedingCount(count);
  String get milkAmount => AppStrings.milkAmount;
  String get milkAmountSelector => AppStrings.milkAmountSelector;
  String get customMl => AppStrings.customMl;
  String get feedingPageTitle => AppStrings.feedingPageTitle;
  String get milkSourceLabel => AppStrings.milkSourceLabel;
  String get breastMilkOption => AppStrings.breastMilkOption;
  String get formulaMilkOption => AppStrings.formulaMilkOption;
  String get mixedMilkOption => AppStrings.mixedMilkOption;
  String get milkAmountLabel => AppStrings.milkAmountLabel;
  String get milkAmountSelectorTitle => AppStrings.milkAmountSelectorTitle;
  String get customMlOption => AppStrings.customMlOption;
  String get foodAmountSelectorTitle => AppStrings.foodAmountSelectorTitle;
  String get totalAmountSelectorTitle => AppStrings.totalAmountSelectorTitle;
  String get customKcal => AppStrings.customKcal;
  String get kcalUnit => AppStrings.kcalUnit;
  String get mlUnit => AppStrings.mlUnit;

  // ==================== 用药模块 ====================
  String get medication => AppStrings.medication;
  String get medicationRecord => AppStrings.medicationRecord;
  String medicationCount(int count) => AppStrings.getMedicationCount(count);
  String get recordMedication => AppStrings.recordMedication;
  String get add => AppStrings.add;
  String get manage => AppStrings.manage;
  String get commonMedications => AppStrings.commonMedications;
  String get enterMedicationName => AppStrings.enterMedicationName;
  String get selectDosage => AppStrings.selectDosage;
  List<String> get commonMedicationList => AppStrings.commonMedicationList;

  // ==================== 尿布模块 ====================
  String get diaper => AppStrings.diaper;
  String get diaperRecord => AppStrings.diaperRecord;
  String diaperCount(int count) => AppStrings.getDiaperCount(count);
  String get poop => AppStrings.poop;
  String get pee => AppStrings.pee;
  String get poopPee => AppStrings.poopPee;
  String get diaperStatus => AppStrings.diaperStatus;
  String get diaperPageTitle => AppStrings.diaperPageTitle;
  String get diaperStatusLabel => AppStrings.diaperStatusLabel;
  String get notesHint => AppStrings.notesHint;
  String get saveButton => AppStrings.saveButton;
  String get deleteRecordButton => AppStrings.deleteRecordButton;
  String get urineColor => AppStrings.urineColor;
  String get urineCharacteristics => AppStrings.urineCharacteristics;
  String get multipleChoice => AppStrings.multipleChoice;
  String get urineCrystal => AppStrings.urineCrystal;
  String get cloudyUrine => AppStrings.cloudyUrine;
  String get bloodInUrine => AppStrings.bloodInUrine;

  // 颜色选项
  String get white => AppStrings.white;
  String get lightYellow => AppStrings.lightYellow;
  String get amber => AppStrings.amber;
  String get orangeYellow => AppStrings.orangeYellow;
  String get tan => AppStrings.tan;
  String get pink => AppStrings.pink;

  // ==================== 辅食模块 ====================
  String get solidFood => AppStrings.solidFood;
  String get solidFoodRecord => AppStrings.solidFoodRecord;
  String solidFoodCount(int count) => AppStrings.getSolidFoodCount(count);
  String get eating => AppStrings.eating;
  String get solidFoodAmount => AppStrings.solidFoodAmount;
  String get quantity => AppStrings.quantity;
  String get foodType => AppStrings.foodType;
  String get multipleSelect => AppStrings.multipleSelect;
  String get foodTexture => AppStrings.foodTexture;

  // 辅食类型列表
  List<String> get foodTypeList => AppStrings.foodTypeList;

  // 辅食性状选项
  String get liquid => AppStrings.liquid;
  String get puree => AppStrings.puree;
  String get minced => AppStrings.minced;
  String get granular => AppStrings.granular;
  String get smallPieces => AppStrings.smallPieces;
  String get largePieces => AppStrings.largePieces;

  // ==================== 睡眠模块 ====================
  String get sleep => AppStrings.sleep;
  String get sleepRecord => AppStrings.sleepRecord;
  String sleepCount(int count) => AppStrings.getSleepCount(count);
  String get startTime => AppStrings.startTime;
  String get endTime => AppStrings.endTime;
  String get sleepPageTitle => AppStrings.sleepPageTitle;
  String get sleepNotesHint => AppStrings.sleepNotesHint;
  String get genericNotesHint => AppStrings.genericNotesHint;

  // ==================== 其他功能 ====================
  String get milestone => AppStrings.milestone;
  String get formula => AppStrings.formula;
  String get pump => AppStrings.pump;
  String get temperature => AppStrings.temperature;
  String get self => AppStrings.self;
  String get healing => AppStrings.healing;
  String get breastfeed => AppStrings.breastfeed;
  String get custom => AppStrings.custom;
  String get customPageTitle => AppStrings.customPageTitle;
  String get eventNameLabel => AppStrings.eventNameLabel;
  String get enterEventNameHint => AppStrings.enterEventNameHint;

  // ==================== 设置/操作 ====================
  String get customSort => AppStrings.customSort;
  String get addToHome => AppStrings.addToHome;
  String get recordTime => AppStrings.recordTime;
  String get notes => AppStrings.notes;
  String get optionalHint => AppStrings.optionalHint;
  String get save => AppStrings.save;
  String get cancel => AppStrings.cancel;
  String get confirm => AppStrings.confirm;

  // ==================== 备注提示文本 ====================
  String get feedingNotesHint => AppStrings.feedingNotesHint;
  String get diaperNotesHint => AppStrings.diaperNotesHint;
  String get medicationNotesHint => AppStrings.medicationNotesHint;
  String get solidFoodNotesHint => AppStrings.solidFoodNotesHint;
  String get awarenessNotesHint => AppStrings.awarenessNotesHint;
  String get healingNotesHint => AppStrings.healingNotesHint;
  String get trueSelfNotesHint => AppStrings.trueSelfNotesHint;
  String get learningTeachingNotesHint => AppStrings.learningTeachingNotesHint;

  // ==================== 便捷访问方法 ====================

  /// 获取睡眠时长文本
  String getSleepDurationText(int hours, int minutes) {
    return AppStrings.getSleepDurationText(hours, minutes);
  }

  /// 静态访问方法，用于获取当前上下文的本地化实例
  static AppLocalizations of(BuildContext context) {
    return const AppLocalizations();
  }
}