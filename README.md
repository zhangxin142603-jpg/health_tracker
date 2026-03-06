# 健康记录应用

一个简单的Flutter安卓应用，用于记录每日喝水喝药情况，数据存储在本地JSON文件中。

## 功能特性

### 📊 记录喝水
- 记录每次喝水的量（毫升）
- 提供快速选择按钮：100ml, 200ml, 250ml, 300ml, 500ml
- 支持自定义输入水量
- 查看今日喝水记录和总量统计

### 💊 记录吃药
- 记录药物名称、剂量、时间
- 支持添加备注信息
- 查看今日吃药记录

### 📈 数据概览
- 显示今日喝水总量
- 显示今日吃药次数
- 查看最近的喝水喝药记录
- 支持删除记录

### 💾 数据存储
- 数据存储在本地JSON文件（`health_data.json`）
- 自动保存，无需手动同步
- 应用重启后数据不会丢失

## 技术栈

- **Flutter 3.41.4** - 跨平台UI框架
- **Provider 6.1.2** - 状态管理
- **JSON序列化** - 数据持久化
- **Path Provider** - 本地文件存储
- **Material Design 3** - 现代化UI

## 项目结构

```
lib/
├── main.dart              # 应用入口和主界面
├── models/               # 数据模型
│   ├── water_entry.dart     # 喝水记录模型
│   ├── medication_entry.dart # 吃药记录模型
│   └── health_data.dart     # 主数据模型
├── providers/            # 状态管理
│   └── health_provider.dart # 健康数据Provider
└── services/            # 服务层
    └── health_storage.dart  # 本地存储服务
```

## 快速开始

### 前提条件
- Flutter SDK 3.0+
- Android SDK（用于安卓构建）
- Java JDK 17+

### 运行应用

1. 克隆项目或下载源代码
2. 安装依赖：
   ```bash
   flutter pub get
   ```
3. 生成JSON序列化代码：
   ```bash
   flutter pub run build_runner build
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

### 记录喝水
1. 点击底部导航栏的"喝水"标签
2. 选择预设水量或输入自定义水量
3. 点击"记录"按钮
4. 记录会自动保存并显示在列表中

### 记录吃药
1. 点击底部导航栏的"吃药"标签
2. 填写药物名称和剂量
3. （可选）填写备注信息
4. 点击"记录"按钮
5. 记录会自动保存并显示在列表中

### 查看数据
1. 点击底部导航栏的"概览"标签
2. 查看今日统计信息
3. 查看最近的喝水喝药记录
4. 点击删除图标可删除记录

## 数据存储

应用数据存储在设备的应用文档目录中：
- Android: `/data/data/com.example.health_tracker/app_flutter/health_data.json`
- 数据格式为JSON，方便备份和恢复

## 开发说明

### 添加新功能
1. 在`models/`目录中添加新的数据模型
2. 使用JSON注解标记模型类
3. 运行`flutter pub run build_runner build`生成序列化代码
4. 在`health_provider.dart`中添加业务逻辑
5. 在UI中添加相应的界面组件

### 修改数据模型
如果修改了数据模型，需要：
1. 更新模型类
2. 运行`flutter pub run build_runner build --delete-conflicting-outputs`
3. 更新存储和Provider逻辑

## 许可证

MIT License - 自由使用和修改