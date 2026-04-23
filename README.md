# Health Tracker App

> 自我追踪应用 — 记录每日健康行为、情绪觉察与个人成长

## 项目概述

| 项目 | 信息 |
|------|------|
| 框架 | Flutter 3.x |
| 语言 | Dart |
| 状态管理 | Provider |
| 国际化 | flutter_localizations + intl |
| 存储 | path_provider + JSON 本地文件 |
| UI | Material Design 3 + 自定义渐变主题 |
| 默认语言 | 简体中文 (zh_CN) |

## 核心功能

| 模块 | 功能 |
|------|------|
| 投喂记录 | 喂水 / 喂食 / 喂食+喂水，kcal/mL 双单位 |
| 解便记录 | 干/湿/混合，尿液颜色、症状标记 |
| 睡眠记录 | 开始/结束时间，自动计算睡眠时长 |
| 辅食记录 | 摄入状态、份量、食物类型、质地 |
| 运动记录 | 带时长追踪 |
| 觉察记录 | 情绪觉察类条目 |
| 疗愈记录 | 疗愈活动追踪 |
| 真我记录 | 自我探索追踪 |
| 自定义记录 | 自由命名 + 笔记 |
| 目标管理 | 每日饮水目标(kcal)、饮食目标(千卡)、体重目标(kg) |
| 用户档案 | 头像、昵称、口号 |
| 统计卡片 | SPT熟练度、真我显现度、子人格图鉴 |

## 架构图

```
lib/
├── main.dart                          # 入口、主题、HomePage、时间线
├── constants/
│   └── emojis.dart                    # 全局 Emoji 常量
├── l10n/
│   ├── app_localizations.dart         # 国际化代理
│   └── strings.dart                   # 字符串资源
├── models/
│   ├── app_data.dart                  # AppData 根模型
│   ├── baby_entries.dart              # 所有 Entry 数据模型（7个）
│   ├── health_data.dart               # HealthData（json_serializable）
│   ├── medication_entry.dart          # MedicationEntry（json_serializable）
│   └── water_entry.dart               # WaterEntry（json_serializable）
├── providers/
│   ├── app_provider.dart              # 主状态管理（7类记录 + 档案 + 目标）
│   └── health_provider.dart           # 健康数据 Provider（water + medication）
├── screens/
│   ├── custom_page.dart               # 自定义记录页
│   ├── diaper_page.dart               # 解便记录页
│   ├── feeding_page.dart              # 投喂记录页（编辑/新建）
│   ├── generic_record_page.dart       # 通用记录页（运动/觉察/疗愈/真我）
│   ├── medication_page.dart           # 疗愈/药物页
│   ├── profile_page.dart              # 用户档案页
│   ├── sleep_page.dart               # 睡眠记录页
│   ├── solid_food_page.dart          # 辅食记录页
│   └── webview_page.dart             # WebView 内嵌页
└── services/
    ├── app_storage.dart              # AppData JSON 持久化
    └── health_storage.dart           # HealthData JSON 持久化
```

## 数据流向

```
用户操作
    │
    ▼
Screen (StatefulWidget)
    │
    ▼
Provider (ChangeNotifier)
    │
    ├── notifyListeners() → UI 自动重建
    │
    └── _save() → AppStorage / HealthStorage
                      │
                      ▼
               JSON 文件 (应用文档目录)
```

## 数据模型

### AppData（根模型）

存储于 `baby_app_data.json`，包含7类记录 + 用户档案 + 目标：

| 字段 | 类型 | 默认值 |
|------|------|--------|
| `feedingEntries` | `List<FeedingEntry>` | `[]` |
| `medEntries` | `List<MedEntry>` | `[]` |
| `diaperEntries` | `List<DiaperEntry>` | `[]` |
| `solidFoodEntries` | `List<SolidFoodEntry>` | `[]` |
| `sleepEntries` | `List<SleepEntry>` | `[]` |
| `genericEntries` | `List<GenericEntry>` | `[]` |
| `customEntries` | `List<CustomEntry>` | `[]` |
| `waterGoalMl` | `int` | `2000` |
| `foodGoalKcal` | `int` | `2200` |
| `weightGoalKg` | `int` | `75` |
| `userName` | `String` | `'张新'` |
| `userMotto` | `String` | `'口号凡是不轻松的时刻都是对生命的浪费！'` |
| `userAvatarPath` | `String` | `''` |

### Entry 模型概览

| 模型 | 时间字段 | 特有字段 |
|------|---------|---------|
| `FeedingEntry` | `timestamp` | `amountMl`, `milkSource`, `foodAmountKcal`, `waterAmountMl` |
| `MedEntry` | `timestamp` | `medicines` (List<String>) |
| `DiaperEntry` | `timestamp` | `diaperType`, `urineColor`, `symptoms` |
| `SolidFoodEntry` | `timestamp` | `ate`, `amount`, `unit`, `foodTypes`, `texture` |
| `SleepEntry` | `startTime`, `endTime?` | `notes` |
| `GenericEntry` | `startTime`, `endTime?` | `type`（锻炼/觉察/疗愈/真我/睡眠） |
| `CustomEntry` | `startTime`, `endTime?` | `eventName`, `notes` |

## 主题色

| 变量 | 值 | 用途 |
|------|----|------|
| `kPrimary` | `#7B6CF6` | 主色调（紫色） |
| `kPrimaryLight` | `#9B8FF9` | 浅紫色 |
| `kBgLight` | `#EAE7FF` | 浅背景 |
| `kDateText` | `#2A1F6A` | 日期文字 |
| `kSubtitleText` | `#8B85B5` | 副标题文字 |

## 依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
  provider: ^6.0.0
  path_provider: ^2.0.0
  json_annotation: ^4.8.0
  package_info_plus: ^4.0.0
  url_launcher: ^6.0.0
  webview_flutter: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

## 开发命令

```bash
# 安装依赖
flutter pub get

# 生成 json_serializable 代码
flutter pub run build_runner build --delete-conflicting-outputs

# 运行 Debug 版本
flutter run

# 构建 Release APK
flutter build apk --release
```
