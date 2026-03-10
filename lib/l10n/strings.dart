/// 应用字符串常量定义
/// 按功能模块组织，便于管理和查找
class AppStrings {
  // ==================== 应用通用 ====================
  static const String appTitle = '完美状态';
  static const String noRecords = '暂无记录';
  static const String clickToAdd = '点击下方按钮添加记录';
  static const String todayNoRecords = '今天暂无记录';
  static const String today = '今天';
  static const String all = '全部';
  static const String inviteFriends = '邀请好友';
  static const String todayRecordsSummary = '今日记录情况';
  static const String collapseDetails = '收起详情';
  static const String expandDetails = '展开详情';
  static const String feedingSummaryLabel = '投喂';
  static const String diaperSummaryLabel = '解便';
  static const String sleepSummaryLabel = '睡眠';
  static const String totalMlLabel = '共{mL}mL';
  static const String timesLabel = '{count}次';

  // ==================== 时间描述 ====================
  static const String justNow = '刚刚';
  static const String minutesAgo = '分钟前';
  static const String hoursAgo = '小时前';
  static const String hoursMinutesAgo = '小时\n分钟前';
  static const String inProgress = '进行中';
  static const String date = '日期';
  static const String time = '时间';

  // ==================== 喂养模块 ====================
  static const String feeding = '投喂';
  static const String feedingRecord = '投喂记录';
  static const String feedingCount = '投喂 {count}次';
  static const String milkAmount = '水量';
  static const String milkAmountSelector = '选择水量';
  static const String customMl = '自定义 (mL)';
  static const String bottleFeeding = '投喂';
  static const String breastMilk = '喂水';
  static const String formulaMilk = '喂食';
  static const String mixedMilk = '喂食+喂水';
  static const String milkSource = '投喂类型';
  static const String customMlInput = '自定义 mL';
  static const String feedingPageTitle = '投喂记录';
  static const String milkSourceLabel = '投喂类型';
  static const String breastMilkOption = '喂水';
  static const String formulaMilkOption = '喂食';
  static const String mixedMilkOption = '喂食+喂水';
  static const String milkAmountLabel = '水量';
  static const String milkAmountSelectorTitle = '水量选择';
  static const String customMlOption = '自定义 mL';

  // ==================== 用药模块 ====================
  static const String medication = '觉察';
  static const String medicationRecord = '觉察记录';
  static const String medicationCount = '觉察 {count}次';
  static const String recordMedication = '记录疗愈';
  static const String add = '添加';
  static const String manage = '管理';
  static const String commonMedications = '常用疗愈';
  static const String enterMedicationName = '请输入药品名称';
  static const String selectDosage = '选择剂量';
  static const List<String> commonMedicationList = [
    '布洛芬',
    '对乙酰氨基酚',
    '维生素D',
    '益生菌',
    '其他'
  ];

  // ==================== 尿布模块 ====================
  static const String diaper = '解便';
  static const String diaperRecord = '解便记录';
  static const String diaperCount = '解便 {count}次';
  static const String poop = '解大';
  static const String pee = '解小';
  static const String poopPee = '解大+解小';
  static const String diaperStatus = '解便类型';
  static const String diaperPageTitle = '解便记录';
  static const String diaperStatusLabel = '解便类型';
  static const String notesHint = '选填';
  static const String saveButton = '保存';
  static const String deleteRecordButton = '删除这条记录';
  static const String urineColor = '尿液颜色';
  static const String urineCharacteristics = '尿液特征';
  static const String multipleChoice = '多选';
  static const String urineCrystal = '尿结晶';
  static const String cloudyUrine = '浑浊尿';
  static const String bloodInUrine = '血尿';
  static const String white = '白色';
  static const String lightYellow = '淡黄色';
  static const String amber = '琥珀色';
  static const String orangeYellow = '橙黄色';
  static const String tan = '棕褐色';
  static const String pink = '粉色';

  // ==================== 睡眠模块 ====================
  static const String sleep = '睡眠';
  static const String sleepRecord = '睡眠';
  static const String sleepCount = '睡眠 {count}次';
  static const String startTime = '开始时间';
  static const String endTime = '结束时间';
  static const String sleepPageTitle = '睡眠记录';
  static const String sleepNotesHint = '选填';

  // ==================== 辅食模块 ====================
  static const String solidFood = '辅食';
  static const String solidFoodRecord = '辅食记录';
  static const String solidFoodCount = '辅食 {count}次';
  static const String eating = '进食';
  static const String foodAmount = '食量';
  static const String quantity = '数量';
  static const String foodType = '食物类型';
  static const String multipleSelect = '多选';
  static const String foodTexture = '食物性状';
  static const List<String> foodTypeList = [
    '水果',
    '蔬菜',
    '谷物',
    '蛋白质',
    '乳制品',
    '其他'
  ];
  static const String liquid = '液体';
  static const String puree = '泥状';
  static const String minced = '碎末';
  static const String granular = '颗粒';
  static const String smallPieces = '小块';
  static const String largePieces = '大块';
  static const String solidFoodNotesHint = '选填';

  // ==================== 其他功能 ====================
  static const String milestone = '锻炼';
  static const String formula = '未命名2';
  static const String pump = '真我';
  static const String temperature = '觉察';
  static const String breastfeed = '未命名';
  static const String custom = '自定义';
  static const String eventName = '事件名';
  static const String enterEventName = '请输入事件名称';
  static const String customPageTitle = '自定义记录';
  static const String eventNameLabel = '事件名';
  static const String enterEventNameHint = '请输入事件名称';

  // ==================== 设置/操作 ====================
  static const String customSort = '自定义排序';
  static const String addToHome = '添加到首页';
  static const String recordTime = '记录时间';
  static const String optionalHint = '选填';
  static const String notes = '备注';
  static const String save = '保存';
  static const String cancel = '取消';
  static const String confirm = '确定';
  static const String deleteRecord = '删除这条记录';

  // ==================== 备注提示文本 ====================
  static const String feedingNotesHint = '选填';
  static const String diaperNotesHint = '选填';
  static const String medicationNotesHint = '选填';
  static const String generalNotesHint = '选填';
  static const String optionalNotesHint = '选填';
  static const String genericNotesHint = '选填';

  // ==================== 格式化方法 ====================
  /// 格式化带计数的字符串
  static String formatCount(String template, int count) {
    return template.replaceAll('{count}', count.toString());
  }

  /// 投喂计数
  static String getFeedingCount(int count) => formatCount(feedingCount, count);

  /// 觉察计数
  static String getMedicationCount(int count) => formatCount(medicationCount, count);

  /// 解便计数
  static String getDiaperCount(int count) => formatCount(diaperCount, count);


  /// 睡眠计数
  static String getSleepCount(int count) => formatCount(sleepCount, count);

  /// 辅食计数
  static String getSolidFoodCount(int count) => formatCount(solidFoodCount, count);

  /// 时间格式化：分钟前
  static String getMinutesAgo(int minutes) => '$minutes$minutesAgo';

  /// 时间格式化：小时前
  static String getHoursAgo(int hours) => '$hours$hoursAgo';

  /// 时间格式化：小时和分钟前
  static String getHoursMinutesAgo(int hours, int minutes) {
    return hoursMinutesAgo
        .replaceFirst('小时', '$hours小时')
        .replaceFirst('\n分钟前', '$minutes分钟前');
  }

  /// 获取睡眠时长文本
  static String getSleepDurationText(int hours, int minutes) {
    if (hours > 0) {
      return minutes > 0 ? '$hours小时$minutes分' : '$hours小时';
    }
    return '$minutes分';
  }
}