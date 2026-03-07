/// 应用字符串常量定义
/// 按功能模块组织，便于管理和查找
class AppStrings {
  // ==================== 应用通用 ====================
  static const String appTitle = '宝宝记录';
  static const String all = '全部';
  static const String inviteFriends = '邀请好友';
  static const String noRecords = '还没有记录';
  static const String clickToAdd = '点击下方按钮添加';
  static const String todayNoRecords = '今日暂无记录';
  static const String today = '今天';

  // ==================== 时间描述 ====================
  static const String justNow = '刚刚';
  static const String minutesAgo = '分钟前';
  static const String hoursAgo = '小时前';
  static const String hoursMinutesAgo = '小时\n分钟前';
  static const String inProgress = '进行中';

  // ==================== 喂养模块 ====================
  static const String feeding = '喂水';
  static const String feedingRecord = '喂水记录';
  static const String feedingCount = '喂水 {count}次';
  static const String milkAmount = '水量';
  static const String milkAmountSelector = '选择水量';
  static const String customMl = '自定义 (mL)';

  // ==================== 用药模块 ====================
  static const String medication = '疗愈';
  static const String medicationRecord = '疗愈记录';
  static const String medicationCount = '用药 {count}次';
  static const String recordMedication = '记录子人格';
  static const String add = '+ 添加';
  static const String manage = '管理';
  static const String commonMedications = '常见子人格';
  static const String enterMedicationName = '请输入子人格名称';
  static const String selectDosage = '选择类型';
  static const String uploadPhoto = '上传照片';

  // 常用药品列表
  static const List<String> commonMedicationList = [
    '焦虑',
    '恐惧',
    '不自信',
    '孤独',
    '愤怒',
    '委屈',
    '拖延',
    '烦躁',
  ];

  // ==================== 尿布模块 ====================
  static const String diaper = '换尿布';
  static const String diaperRecord = '换尿布记录';
  static const String diaperCount = '换尿布 {count}次';
  static const String poop = '大便';
  static const String pee = '小便';
  static const String poopPee = '大便+小便';
  static const String diaperStatus = '尿布状态';
  static const String urineColor = '小便颜色';
  static const String urineCharacteristics = '小便伴随性状';
  static const String multipleChoice = '（多选）';
  static const String urineCrystal = '尿布有结晶沉淀';
  static const String cloudyUrine = '尿液浑浊';
  static const String bloodInUrine = '尿中带血';

  // 颜色选项
  static const String white = '白色';
  static const String lightYellow = '淡黄色';
  static const String amber = '琥珀色';
  static const String orangeYellow = '橙黄色';
  static const String tan = '棕褐色';
  static const String pink = '粉红色';

  // ==================== 辅食模块 ====================
  static const String solidFood = '喂食';
  static const String solidFoodRecord = '喂食记录';
  static const String solidFoodCount = '辅食 {count}次';
  static const String eating = '是否进食';
  static const String foodAmount = '进食量';
  static const String quantity = '数量';
  static const String foodType = '食物类型';
  static const String multipleSelect = '可多选';
  static const String foodTexture = '食物性状';

  // 辅食类型列表
  static const List<String> foodTypeList = [
    '谷物',
    '肉类',
    '水产',
    '蔬菜',
    '水果',
    '其他'
  ];

  // 辅食性状选项
  static const String liquid = '液体';
  static const String puree = '泥糊状';
  static const String minced = '碎末状';
  static const String granular = '颗粒状';
  static const String smallPieces = '小块状';
  static const String largePieces = '大块状';

  // ==================== 睡眠模块 ====================
  static const String sleep = '睡眠';
  static const String sleepRecord = '睡眠记录';
  static const String sleepCount = '睡眠 {count}次';
  static const String startTime = '开始时间';
  static const String endTime = '结束时间';

  // ==================== 其他功能 ====================
  static const String milestone = '里程碑';
  static const String formula = '奶粉喂养';
  static const String pump = '泵奶';
  static const String temperature = '体温';
  static const String breastfeed = '母乳亲喂';
  static const String custom = '自定义';

  // ==================== 设置/操作 ====================
  static const String customSort = '自定义排序';
  static const String addToHome = '添加到首页';
  static const String recordTime = '记录时间';
  static const String notes = '备注';
  static const String optionalHint = '选填';
  static const String save = '保存';
  static const String cancel = '取消';
  static const String confirm = '确定';

  // ==================== 备注提示文本 ====================
  static const String feedingNotesHint = '选填，比如宝宝是否有吐奶、肠胀气等不适情况';
  static const String diaperNotesHint = '选填，比如宝宝尿尿时是否有发烧、哭闹等';
  static const String medicationNotesHint = '选填，比如药品名称、规格、作用等，进一步完善用药信息';
  static const String sleepNotesHint = '选填，比如宝宝睡觉时出现的小问题、睡眠环境等';
  static const String solidFoodNotesHint = '选填，比如新添加的食物名称、是否过敏等';

  // ==================== 格式化方法 ====================
  /// 格式化带计数的字符串
  static String formatCount(String template, int count) {
    return template.replaceAll('{count}', count.toString());
  }

  /// 喂养计数
  static String getFeedingCount(int count) => formatCount(feedingCount, count);

  /// 用药计数
  static String getMedicationCount(int count) => formatCount(medicationCount, count);

  /// 尿布计数
  static String getDiaperCount(int count) => formatCount(diaperCount, count);

  /// 辅食计数
  static String getSolidFoodCount(int count) => formatCount(solidFoodCount, count);

  /// 睡眠计数
  static String getSleepCount(int count) => formatCount(sleepCount, count);

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