# 完美状态 - 身心健康记录应用

<p align="center">
  <strong>版本 v1.2.1</strong> | 一个功能丰富的Flutter应用，用于追踪日常活动和个人身心健康记录
</p>

![Flutter](https://img.shields.io/badge/Flutter-3.11.1+-blue)
![Dart](https://img.shields.io/badge/Dart-3.2.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android-lightgrey)

一个现代化的身心健康记录应用，支持记录和个人健康追踪。数据安全存储在本地，界面美观易用，功能全面。

## ✨ 核心特性

### 👶 婴记录
- **喂养记录**：记录喂水、喂食或两者混合，支持自定义食量（kcal）和水量（mL）
- **解便记录**：记录解小、解大或两者，支持记录尿液颜色和症状
- **睡眠记录**：记录睡眠开始和结束时间，自动计算睡眠时长
- **辅食记录**：记录固体食物摄入，支持食物类型和食量记录

### 🧘‍♀️ 个人健康管理
- **锻炼记录**：记录运动活动，追踪健身进度
- **正念觉察**：记录冥想和正念练习时刻
- **疗愈记录**：记录身心疗愈活动
- **真我记录**：记录自我成长和反思时刻
- **自定义记录**：创建个性化的记录类型，满足多样化需求

### 👤 个人资料系统
- **用户信息管理**：设置姓名、头像、生日等个人信息
- **健康目标设定**：设定每日喝水、运动、睡眠等目标
- **头像上传**：支持从相册选择或拍照设置个人头像
- **应用信息**：查看版本号、检查更新

### 🌐 扩展功能
- **内置WebView**：集成网页浏览功能，可查看外部健康资源
- **版本检查**：自动检查应用更新（支持蒲公英分发平台）
- **外部链接**：一键打开相关健康网站和资源

### 📊 数据可视化与管理
- **时间线视图**：按时间顺序智能显示所有记录，清晰直观
- **今日摘要**：可展开/折叠的今日活动统计面板
- **智能日期导航**：支持查看任意日期的历史记录
- **记录管理**：完整的编辑、删除功能，数据操作简单高效

### 💾 数据存储与安全
- **本地JSON存储**：数据存储在设备本地`baby_app_data.json`文件
- **零网络依赖**：所有数据仅存本地，无需网络连接
- **自动保存**：添加/编辑记录后自动保存，无需手动同步
- **数据持久化**：应用重启后数据完整保留

## 🚀 技术栈

- **Flutter 3.11.1+** - 现代化跨平台UI框架
- **Dart 3.2.0+** - 强类型编程语言
- **Provider 6.1.2** - 高效的状态管理方案
- **Material Design 3** - 现代化的设计语言
- **Path Provider 2.1.3** - 安全的本地文件存储路径管理
- **JSON序列化** - 轻量级数据持久化方案
- **国际化支持** - 使用Intl库支持多语言

### 核心依赖
```yaml
provider: ^6.1.2        # 状态管理
path_provider: ^2.1.3   # 文件路径
webview_flutter: ^4.2.2 # 网页浏览
package_info_plus: ^8.0.0 # 应用信息
http: ^1.2.2            # 网络请求
url_launcher: ^6.3.0    # 外部链接
image_picker: ^1.1.2    # 图片选择
intl: ^0.20.2           # 国际化
```

## 📁 项目结构

```
lib/
├── main.dart                    # 应用入口和主界面
├── models/                      # 数据模型层
│   ├── baby_entries.dart        # 核心数据模型（喂养、尿布、睡眠等）
│   ├── app_data.dart            # 应用主数据容器
│   ├── health_data.dart         # 健康数据模型（历史兼容）
│   └── medication_entry.dart    # 药物记录模型
├── providers/                   # 状态管理层
│   ├── app_provider.dart        # 新版应用状态管理（核心）
│   └── health_provider.dart     # 旧版健康数据Provider（兼容）
├── screens/                     # 界面页面层
│   ├── feeding_page.dart        # 喂养记录页面
│   ├── diaper_page.dart         # 尿布记录页面
│   ├── sleep_page.dart          # 睡眠记录页面
│   ├── solid_food_page.dart     # 辅食记录页面
│   ├── generic_record_page.dart # 通用记录页面（锻炼、觉察等）
│   ├── custom_page.dart         # 自定义记录页面
│   ├── medication_page.dart     # 药物记录页面（历史功能）
│   ├── profile_page.dart        # 个人资料页面（新增）
│   └── webview_page.dart        # WebView页面（新增）
├── services/                    # 服务层
│   ├── app_storage.dart         # 新版数据存储服务
│   └── health_storage.dart      # 旧版数据存储服务
├── constants/                   # 常量定义
│   └── emojis.dart              # Emoji表情常量
└── l10n/                        # 国际化支持
    ├── app_localizations.dart   # 本地化代理
    └── strings.dart             # 字符串资源
```

## ⚡ 快速开始

### 环境要求
- **Flutter SDK**: 3.11.1 或更高版本
- **Android SDK**: 用于安卓构建
- **Java JDK**: 17 或更高版本
- **IDE推荐**: Android Studio 或 VS Code 配合 Flutter 插件

### 运行步骤
1. **克隆项目**
   ```bash
   git clone https://github.com/zhangxin142603-jpg/health_tracker.git
   cd health_tracker
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成应用图标**（可选）
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **连接设备**
   - 连接Android真机（开启USB调试）
   - 或启动Android模拟器

5. **运行应用**
   ```bash
   flutter run
   ```

6. **构建发布版APK**
   ```bash
   flutter build apk --release
   ```

## 📱 使用指南

### 主界面导航
- **时间线视图**：按时间顺序显示当天的所有记录
- **日期选择器**：点击顶部日期可切换查看不同日期的记录
- **今日摘要面板**：显示当日各类记录的统计摘要，可点击展开查看详情
- **底部功能栏**：两行共8个功能按钮，快速进入不同记录页面

### 记录操作流程
1. **添加喂养记录**：点击"投喂"按钮 → 选择类型 → 设置食量/水量 → 添加备注
2. **添加尿布记录**：点击"解便"按钮 → 选择类型 → 记录尿液颜色/症状
3. **添加睡眠记录**：点击"睡眠"按钮 → 设置开始时间 → 自动计算时长
4. **添加健康记录**：点击相应按钮 → 记录活动内容 → 保存
5. **自定义记录**：点击"自定义"按钮 → 输入事件名称 → 创建个性化记录

### 个人资料功能
- **访问路径**：点击主界面右上角用户图标
- **设置头像**：点击头像区域，选择拍照或从相册选择
- **修改信息**：点击相应卡片编辑个人信息
- **查看版本**：底部显示当前版本号，可检查更新
- **健康目标**：设定每日目标，追踪完成进度

### 数据管理
- **查看历史**：使用日期选择器查看任意日期记录
- **编辑记录**：点击时间线中任意记录卡片进入编辑
- **删除记录**：在编辑页面点击底部删除按钮
- **数据备份**：手动备份`baby_app_data.json`文件

## 🔧 开发指南

### 架构概述
- **状态管理**：采用Provider模式，核心状态类为`AppProvider`
- **数据模型**：核心模型定义在`baby_entries.dart`中，使用手写序列化
- **数据存储**：`AppStorage`类负责JSON文件的读写操作
- **界面分层**：主界面在`main.dart`，各功能页面在`screens/`目录
- **依赖注入**：通过Provider实现依赖管理，代码解耦清晰

### 添加新记录类型
1. **定义数据模型**：在`baby_entries.dart`中添加新类，实现`toJson()/fromJson()`
2. **更新数据容器**：在`app_data.dart`中添加对应列表字段和操作方法
3. **扩展状态管理**：在`app_provider.dart`中添加getter和操作方法
4. **创建界面页面**：参考现有模板创建新页面
5. **集成到主界面**：更新`_buildCard()`方法支持新类型显示
6. **添加功能入口**：在`_buildBottomBar()`方法中添加新按钮

### 修改现有功能
- **更新数据模型**：修改`baby_entries.dart`中的类定义，确保序列化同步
- **调整UI界面**：编辑对应的页面文件
- **修改业务逻辑**：更新`AppProvider`中的相关方法
- **数据迁移**：重大数据结构变更时，在`AppStorage`中添加迁移逻辑

### 版本检查机制
应用集成了蒲公英分发平台的版本检查功能：
- 自动获取当前应用版本号
- 从蒲公英API检查是否有新版本
- 支持手动触发检查更新
- 提供更新链接跳转

## 📈 版本历史

### v1.2.1 (当前版本)
- ✅ 完善版本检查功能，支持蒲公英分发平台
- ✅ 更新依赖锁定文件，确保构建稳定性
- ✅ 优化个人资料页面UI和交互体验

### v1.2.0
- ✅ 添加个人资料页面，支持用户信息管理
- ✅ 集成WebView功能，支持内置网页浏览
- ✅ 添加头像上传和健康目标设定
- ✅ 优化页面过渡动画和视觉效果

### v1.1.0
- ✅ 添加疗愈记录和辅食记录页面
- ✅ 优化主页面UI设计和交互体验
- ✅ 改进数据存储效率和稳定性

### v1.0.0
- ✅ 基础婴儿护理功能（喂养、尿布、睡眠）
- ✅ 个人健康记录（锻炼、觉察、真我、自定义）
- ✅ 时间线视图和今日摘要
- ✅ 本地JSON数据存储

## 🤝 贡献指南

欢迎提交Issue和Pull Request来帮助改进这个项目。

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持与反馈

- **问题反馈**：请使用GitHub Issues报告问题
- **功能建议**：欢迎提交Issue讨论新功能
- **代码贡献**：Pull Request总是受欢迎的

---

<p align="center">
  <em>让记录身心健康成为一种习惯</em>
</p>
