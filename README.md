# 完美状态 - 身心健康记录应用

一个功能丰富的Flutter应用，用于追踪宝宝日常活动和个人身心健康记录，数据存储在本地JSON文件中。

## 功能特性

### 👶 宝宝日常追踪
- **喂养记录**：记录喂水、喂食或两者混合，支持自定义食量（kcal）和水量（mL）
- **尿布记录**：记录解小、解大或两者，支持记录尿液颜色和症状
- **睡眠记录**：记录睡眠开始和结束时间，自动计算睡眠时长
- **固体食物记录**：记录固体食物的摄入情况（数量或mL）

### 🧘 个人健康记录
- **锻炼记录**：记录运动活动
- **觉察记录**：记录正念觉察时刻
- **疗愈记录**：记录疗愈活动
- **真我记录**：记录自我成长时刻
- **自定义记录**：创建个性化的记录类型

### 📊 数据概览
- **时间线视图**：按时间顺序显示所有记录，清晰直观
- **今日摘要**：可展开/折叠的今日活动统计
- **日期选择**：支持查看任意日期的记录
- **记录管理**：支持编辑和删除任何记录

### 💾 数据存储
- 数据存储在本地JSON文件（`app_data.json`）
- 使用Provider进行状态管理
- 自动保存，无需手动同步
- 应用重启后数据不会丢失

## 技术栈

- **Flutter 3.41.4** - 跨平台UI框架
- **Provider 6.1.2** - 状态管理
- **JSON序列化** - 数据持久化（json_annotation + json_serializable）
- **Path Provider 2.1.3** - 本地文件存储
- **Intl 0.20.2** - 国际化支持
- **Material Design 3** - 现代化UI设计
- **Flutter Launcher Icons** - 应用图标生成

## 项目结构

```
lib/
├── main.dart                    # 应用入口和主界面
├── models/                     # 数据模型
│   ├── baby_entries.dart       # 核心数据模型（喂养、尿布、睡眠等）
│   ├── app_data.dart           # 应用主数据模型
│   ├── health_data.dart        # 旧版健康数据模型（兼容）
│   ├── water_entry.dart        # 旧版喝水记录模型
│   └── medication_entry.dart   # 旧版吃药记录模型
├── providers/                  # 状态管理
│   ├── app_provider.dart       # 新版应用状态管理
│   └── health_provider.dart    # 旧版健康数据Provider
├── screens/                    # 界面页面
│   ├── feeding_page.dart       # 喂养记录页面
│   ├── diaper_page.dart        # 尿布记录页面
│   ├── sleep_page.dart         # 睡眠记录页面
│   ├── generic_record_page.dart # 通用记录页面（锻炼、觉察等）
│   ├── custom_page.dart        # 自定义记录页面
│   ├── solid_food_page.dart    # 固体食物记录页面
│   └── medication_page.dart    # 旧版吃药记录页面
├── services/                   # 服务层
│   ├── app_storage.dart        # 新版数据存储服务
│   └── health_storage.dart     # 旧版数据存储服务
├── constants/                  # 常量定义
│   └── emojis.dart             # Emoji常量定义
└── l10n/                       # 国际化
    ├── app_localizations.dart  # 本地化代理
    └── strings.dart            # 字符串定义
```

## 快速开始

### 前提条件
- Flutter SDK 3.11.1+
- Android SDK（用于安卓构建）
- Java JDK 17+

### 运行应用

1. 克隆项目或下载源代码
2. 安装依赖：
   ```bash
   flutter pub get
   ```
3. （可选）生成应用图标：
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```
4. 连接Android设备或启动模拟器
5. 运行应用：
   ```bash
   flutter run
   ```
6. 构建发布APK：
   ```bash
   flutter build apk --release
   ```

## 使用说明

### 主界面
- **时间线视图**：按时间顺序显示当天的所有记录
- **日期选择**：点击顶部日期可切换查看不同日期的记录
- **今日摘要**：显示当日各类记录的统计摘要，可点击展开查看详情
- **底部功能栏**：两行共8个功能按钮，快速进入不同记录页面

### 添加记录
1. **喂养记录**：点击"投喂"按钮，选择喂水/喂食/两者，设置食量或水量，添加备注
2. **尿布记录**：点击"解便"按钮，选择解小/解大/两者，记录尿液颜色和症状
3. **睡眠记录**：点击"睡眠"按钮，设置开始时间（结束时间可选），记录睡眠时长
4. **健康记录**：点击"锻炼"、"觉察"、"疗愈"、"真我"按钮，记录相应活动
5. **自定义记录**：点击"自定义"按钮，创建个性化事件记录

### 管理记录
- **查看记录**：在主界面时间线中查看所有记录
- **编辑记录**：点击任意记录卡片进入编辑页面
- **删除记录**：在编辑页面点击底部"删除这条记录"按钮
- **日期导航**：使用日期选择器查看历史记录

## 数据存储

应用数据存储在设备的应用文档目录中：
- **存储文件**：`baby_app_data.json`
- **Android路径**：`/data/data/com.example.health_tracker/app_flutter/baby_app_data.json`
- **数据格式**：标准JSON格式，包含所有记录类型的数据
- **备份恢复**：可手动备份此文件以保存数据，或替换文件以恢复数据

## 开发说明

### 架构概述
- **状态管理**：使用Provider模式，主状态管理类为`AppProvider`
- **数据模型**：核心模型定义在`baby_entries.dart`中，使用手写序列化方法
- **数据存储**：`AppStorage`类负责JSON文件的读写
- **界面结构**：主界面在`main.dart`中，各功能页面在`screens/`目录下

### 添加新记录类型
1. 在`baby_entries.dart`中添加新的数据模型类，实现`toJson()`和`fromJson()`方法
2. 在`app_data.dart`中添加对应的列表字段和操作方法（如`addXxx`、`removeXxx`）
3. 在`app_provider.dart`中添加对应的getter和操作方法
4. 创建新的界面页面（参考现有页面模板）
5. 在主界面的时间线显示逻辑中添加对新类型的支持（修改`_buildCard()`方法）
6. 在底部功能栏添加新按钮（修改`_buildBottomBar()`方法）

### 修改现有功能
- **更新数据模型**：直接修改`baby_entries.dart`中的类定义，确保序列化方法同步更新
- **修改UI界面**：编辑对应的页面文件
- **修改业务逻辑**：更新`AppProvider`中的相关方法
- **数据迁移**：如果数据结构有重大变更，需要在`AppStorage`中添加数据迁移逻辑

## 许可证

MIT License - 自由使用和修改