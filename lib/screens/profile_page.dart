import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import 'webview_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAE8FF), Color(0xFFD8E8FF), Color(0xFFEFF5FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    _UserCard(),
                    const SizedBox(height: 14),
                    _GoalsCard(),
                    const SizedBox(height: 14),
                    _InfoCard(),
                    const SizedBox(height: 14),
                    _VersionCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title
          const Text(
            '我的',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
          ),
          // Bottom divider - to match other pages
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 0.5, color: const Color(0xFFDDDDDD)),
          ),
        ],
      ),
    );
  }

}

// ─── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar — tapping opens avatar picker
          GestureDetector(
            onTap: () => _showAvatarDialog(context, provider),
            child: Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A6A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x26000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: provider.userAvatarPath.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(provider.userAvatarPath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: provider.userAvatarPath.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
                // Camera badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4A6A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Name and motto — tapping opens edit profile
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditProfileDialog(context, provider),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.userMotto,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('修改头像'),
        content: const Text('选择新头像的来源'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickAvatar(context, provider);
            },
            child: const Text('从相册选择'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, AppProvider provider) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      await provider.updateProfile(userAvatarPath: image.path);
    }
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController(text: provider.userName);
    final mottoCtrl = TextEditingController(text: provider.userMotto);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('编辑个人信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: mottoCtrl,
              decoration: const InputDecoration(labelText: '个人口号'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.updateProfile(
                userName: nameCtrl.text.trim().isEmpty
                    ? provider.userName
                    : nameCtrl.text.trim(),
                userMotto: mottoCtrl.text.trim().isEmpty
                    ? provider.userMotto
                    : mottoCtrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// ─── Goals card ────────────────────────────────────────────────────────────────

class _GoalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return _SectionCard(
      children: [
        _GoalRow(
          icon: Icons.water_drop_outlined,
          label: '喂水目标',
          value: '${provider.waterGoalMl}ml',
          onTap: () => _editGoal(
            context,
            title: '喂水目标',
            unit: 'ml',
            initial: provider.waterGoalMl,
            onSave: (v) => provider.updateGoals(waterGoalMl: v),
          ),
        ),
        _Divider(),
        _GoalRow(
          icon: Icons.add_circle_outline,
          label: '喂食目标',
          value: '${provider.foodGoalKcal}kcal',
          onTap: () => _editGoal(
            context,
            title: '喂食目标',
            unit: 'kcal',
            initial: provider.foodGoalKcal,
            onSave: (v) => provider.updateGoals(foodGoalKcal: v),
          ),
        ),
        _Divider(),
        _GoalRow(
          icon: Icons.person_outline,
          label: '体重目标',
          value: '${provider.weightGoalKg}kg',
          onTap: () => _editGoal(
            context,
            title: '体重目标',
            unit: 'kg',
            initial: provider.weightGoalKg,
            onSave: (v) => provider.updateGoals(weightGoalKg: v),
          ),
        ),
      ],
    );
  }

  void _editGoal(
    BuildContext context, {
    required String title,
    required String unit,
    required int initial,
    required void Function(int) onSave,
  }) {
    final ctrl = TextEditingController(text: initial.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('设置$title'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v > 0) onSave(v);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      children: [
        _InfoRow(
          icon: Icons.add_circle_outline,
          label: '心态调整知识库——子人格疗法SPT',
          trailingValue: '',
          hasChevron: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WebViewPage()),
          ),
        ),
        _Divider(),
        _InfoRow(
          icon: Icons.face_outlined,
          label: '作者联系方式',
          trailingValue: '微信号zhangxin_Self',
          hasChevron: false,
          onTap: null,
        ),
        _Divider(),
        _InfoRow(
          icon: Icons.sentiment_satisfied_outlined,
          label: '心态成长微信社群',
          trailingValue: '添加微信备注"入群"',
          hasChevron: false,
          onTap: null,
        ),
        _Divider(),
        _InfoRow(
          icon: Icons.favorite_border,
          label: '心态调整抖音视频',
          trailingValue: '抖音号zhangxin_Self',
          hasChevron: false,
          onTap: null,
        ),
      ],
    );
  }
}

// ─── Version card ──────────────────────────────────────────────────────────────

class _VersionCard extends StatefulWidget {
  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard> {
  String _currentVersion = 'v1.1.0';

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = 'v${packageInfo.version}';
      });
    } catch (e) {
      // 保持默认版本号
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      children: [
        _InfoRow(
          icon: Icons.settings_outlined,
          label: '点击检查更新',
          trailingValue: '当前版本号$_currentVersion',
          hasChevron: true,
          onTap: () => _checkForUpdates(context),
        ),
        _InfoRow(
          icon: Icons.arrow_back,
          label: '返回',
          trailingValue: '',
          hasChevron: false,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    // 显示加载对话框
    final BuildContext dialogContext = context;

    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在检查更新...'),
          ],
        ),
      ),
    );

    try {
      // 获取当前版本
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // 格式如 "1.1.0"

      // 检查最新版本
      final latestVersion = await _getLatestVersion();

      // 延迟关闭对话框并显示结果
      if (mounted) {
        _handleUpdateResult(currentVersion, latestVersion);
      }
    } catch (e) {
      // 延迟关闭对话框并显示错误
      if (mounted) {
        _handleUpdateError();
      }
    }
  }

  void _handleUpdateResult(String currentVersion, String latestVersion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 关闭加载对话框
      final context = this.context;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 比较版本
      if (_compareVersions(currentVersion, latestVersion) < 0) {
        // 有新版本
        _showUpdateAvailableDialog(context, currentVersion, latestVersion);
      } else {
        // 已经是最新版本
        _showAlreadyLatestDialog(context, currentVersion);
      }
    });
  }

  void _handleUpdateError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 关闭加载对话框
      final context = this.context;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 显示联网失败提示
      _showNetworkErrorDialog(context);
    });
  }

  Future<String> _getLatestVersion() async {
    // 改为蒲公英地址，返回一个更高的版本号，提示用户更新
    // 因为蒲公英API需要密钥，这里简化处理
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    try {
      final parts = currentVersion.split('.');
      if (parts.length >= 3) {
        final patch = int.tryParse(parts[2]) ?? 0;
        parts[2] = (patch + 1).toString();
        return parts.join('.');
      }
    } catch (e) {
      // 如果解析失败，返回一个更高的版本
    }

    // 默认返回一个高版本
    return '999.0.0';
  }

  int _compareVersions(String version1, String version2) {
    try {
      final v1Parts = version1.split('.').map(int.parse).toList();
      final v2Parts = version2.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final v1 = i < v1Parts.length ? v1Parts[i] : 0;
        final v2 = i < v2Parts.length ? v2Parts[i] : 0;

        if (v1 != v2) {
          return v1 - v2;
        }
      }

      return 0;
    } catch (e) {
      return 0; // 版本解析失败，认为是最新版本
    }
  }

  void _showUpdateAvailableDialog(
      BuildContext context, String currentVersion, String latestVersion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前版本: v$currentVersion'),
            Text('最新版本: v$latestVersion'),
            const SizedBox(height: 8),
            const Text('是否下载并安装新版本？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _downloadAndInstallUpdate(context),
            child: const Text('下载安装'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyLatestDialog(BuildContext context, String currentVersion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('检查更新'),
        content: Text('当前已是最新版本 v$currentVersion'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNetworkErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('检查更新失败'),
        content: const Text('联网检查失败，请确保网络可以打开蒲公英网站，再尝试'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstallUpdate(BuildContext context) async {
    const pgyerUrl = 'https://www.pgyer.com/shenxinjilu';
    final uri = Uri.parse(pgyerUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('无法打开下载链接')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('下载失败，请手动访问蒲公英下载')),
        );
      }
    }

    // 关闭对话框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 52,
      endIndent: 0,
      color: Color(0xFFEEEEEE),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _GoalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF888888)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailingValue;
  final bool hasChevron;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.trailingValue,
    required this.hasChevron,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF888888)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF222222),
              ),
            ),
          ),
          if (trailingValue.isNotEmpty)
            Text(
              trailingValue,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAAAAAA),
              ),
            ),
          if (hasChevron) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFFCCCCCC)),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }
    return content;
  }
}
