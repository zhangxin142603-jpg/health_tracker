import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'constants/emojis.dart';
import 'l10n/app_localizations.dart';
import 'models/baby_entries.dart';
import 'providers/app_provider.dart';
import 'screens/custom_page.dart';
import 'screens/diaper_page.dart';
import 'screens/feeding_page.dart';
import 'screens/generic_record_page.dart';
import 'screens/medication_page.dart';
import 'screens/profile_page.dart';
import 'screens/sleep_page.dart';
import 'screens/solid_food_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('zh_CN', null).then((_) {
    runApp(const BabyTrackerApp());
  });
}

const Color kPrimary = Color(0xFF7B6CF6);
const Color kPrimaryLight = Color(0xFF9B8FF9);
const Color kBgLight = Color(0xFFEAE7FF);
const Color kDateText = Color(0xFF2A1F6A);
const Color kSubtitleText = Color(0xFF8B85B5);

// 时间线圆点颜色
const Color kDotAwareness = Color(0xFF7B6CF6);  // 觉察 - 紫色
const Color kDotWater = Color(0xFFFFA726);      // 喝水 - 橙色
const Color kDotFeeding = Color(0xFF66BB6A);    // 投喂 - 绿色
const Color kDotExercise = Color(0xFF42A5F5);   // 运动 - 蓝色
const Color kDotDefault = Color(0xFF9B8FF9);    // 默认 - 浅紫

class BabyTrackerApp extends StatelessWidget {
  const BabyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: AppLocalizations.of(context).appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
          useMaterial3: true,
          fontFamily: 'PingFang SC',
        ),
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'), // 简体中文
        ],
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ─── Unified timeline entry ────────────────────────────────────────────────────

class _Entry {
  final DateTime timestamp;
  final String type;
  final String id;
  final dynamic data;

  _Entry({
    required this.timestamp,
    required this.type,
    required this.id,
    required this.data,
  });
}

// ─── Home Page ─────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  bool _summaryExpanded = false;

  bool _sameDay(DateTime dt) =>
      dt.year == _selectedDate.year &&
      dt.month == _selectedDate.month &&
      dt.day == _selectedDate.day;

  bool _isToday() {
    final now = DateTime.now();
    return now.year == _selectedDate.year &&
        now.month == _selectedDate.month &&
        now.day == _selectedDate.day;
  }

  List<_Entry> _buildEntries(AppProvider p) {
    final all = <_Entry>[
      ...p.feedingEntries
          .where((e) => _sameDay(e.timestamp))
          .map(
            (e) => _Entry(
              timestamp: e.timestamp,
              type: 'feeding',
              id: e.id,
              data: e,
            ),
          ),
      ...p.diaperEntries
          .where((e) => _sameDay(e.timestamp))
          .map(
            (e) => _Entry(
              timestamp: e.timestamp,
              type: 'diaper',
              id: e.id,
              data: e,
            ),
          ),
      ...p.sleepEntries
          .where(
            (e) =>
                _sameDay(e.startTime) ||
                (e.endTime != null && _sameDay(e.endTime!)),
          )
          .map((e) {
            final timestamp = (_sameDay(e.startTime)
                ? e.startTime
                : e.endTime)!;
            return _Entry(
              timestamp: timestamp,
              type: 'sleep',
              id: e.id,
              data: e,
            );
          }),
      ...p.genericEntries
          .where(
            (e) =>
                _sameDay(e.startTime) ||
                (e.endTime != null && _sameDay(e.endTime!)),
          )
          .map((e) {
            final timestamp = (_sameDay(e.startTime)
                ? e.startTime
                : e.endTime)!;
            return _Entry(
              timestamp: timestamp,
              type: 'generic',
              id: e.id,
              data: e,
            );
          }),
      ...p.customEntries
          .where(
            (e) =>
                _sameDay(e.startTime) ||
                (e.endTime != null && _sameDay(e.endTime!)),
          )
          .map((e) {
            final timestamp = (_sameDay(e.startTime)
                ? e.startTime
                : e.endTime)!;
            return _Entry(
              timestamp: timestamp,
              type: 'custom',
              id: e.id,
              data: e,
            );
          }),
      ...p.medEntries
          .where((e) => _sameDay(e.timestamp))
          .map(
            (e) =>
                _Entry(timestamp: e.timestamp, type: 'med', id: e.id, data: e),
          ),
      ...p.solidFoodEntries
          .where((e) => _sameDay(e.timestamp))
          .map(
            (e) => _Entry(
              timestamp: e.timestamp,
              type: 'solidFood',
              id: e.id,
              data: e,
            ),
          ),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all;
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (p != null) setState(() => _selectedDate = p);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final entries = _buildEntries(provider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD8D4FF),
              Color(0xFFEAE7FF),
              Color(0xFFF5F3FF),
            ],
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildStatCards(provider),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? _buildEmpty()
                  : _buildTimeline(context, entries, provider),
            ),
            _buildBottomBar(context, provider),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final label = DateFormat('yyyy.MM.dd').format(_selectedDate);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              child: _buildAvatar(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: kDateText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '持续记录，成为更好的自己 ✨',
                      style: TextStyle(
                        color: kSubtitleText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: kPrimary,
                  size: 22,
                ),
                onPressed: _pickDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    if (provider.userAvatarPath.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: FileImage(File(provider.userAvatarPath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E0FF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '👤',
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      );
    }
  }

  // ─── Stat cards ────────────────────────────────────────────────────────────

  Widget _buildStatCards(AppProvider provider) {
    final selfCount = provider.genericEntries
        .where((e) => e.type == '真我')
        .length;
    final healingCount = provider.genericEntries
        .where((e) => e.type == '疗愈')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _StatCard(
            emoji: '⚙️',
            title: 'SPT熟练度',
            subtitle: '持续练习，稳步提升',
            badge: '88',
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '📈',
            title: '真我显现度',
            subtitle: '探索自我，活出真我',
            badge: '$selfCount',
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '🧩',
            title: '子人格图鉴',
            subtitle: '了解自己，接纳自己',
            badge: null,
          ),
        ],
      ),
    );
  }

  // ─── Empty state ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard_UNUSED(AppProvider provider) {
    final feedCount = provider.feedingEntries
        .where((e) => _sameDay(e.timestamp))
        .toList();
    final diaperList = provider.diaperEntries
        .where((e) => _sameDay(e.timestamp))
        .toList();
    final sleepList = provider.sleepEntries
        .where(
          (e) =>
              _sameDay(e.startTime) ||
              (e.endTime != null && _sameDay(e.endTime!)),
        )
        .toList();
    final genericList = provider.genericEntries
        .where(
          (e) =>
              _sameDay(e.startTime) ||
              (e.endTime != null && _sameDay(e.endTime!)),
        )
        .toList();
    final customList = provider.customEntries
        .where(
          (e) =>
              _sameDay(e.startTime) ||
              (e.endTime != null && _sameDay(e.endTime!)),
        )
        .toList();

    // Build summary parts
    final parts = <String>[];
    if (feedCount.isNotEmpty) parts.add('投喂 ${feedCount.length}次');
    if (diaperList.isNotEmpty) parts.add('解便 ${diaperList.length}次');
    if (sleepList.isNotEmpty) parts.add('睡眠 ${sleepList.length}次');
    for (final t in [
      AppLocalizations.of(context).milestone,
      AppLocalizations.of(context).temperature,
      AppLocalizations.of(context).healing,
      AppLocalizations.of(context).self,
    ]) {
      final cnt = genericList.where((e) => e.type == t).length;
      if (cnt > 0) parts.add('$t $cnt次');
    }
    if (customList.isNotEmpty) parts.add('学与教 ${customList.length}次');

    final summaryText = parts.isEmpty
        ? AppLocalizations.of(context).todayNoRecords
        : '· ${parts.join(' · ')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(10, 0, 0, 0),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).todayRecordsSummary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() => _summaryExpanded = !_summaryExpanded),
                child: Text(
                  _summaryExpanded
                      ? AppLocalizations.of(context).collapseDetails
                      : AppLocalizations.of(context).expandDetails,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
          if (!_summaryExpanded) ...[
            const SizedBox(height: 8),
            Text(
              summaryText,
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
            ),
          ],
          if (_summaryExpanded) ...[
            const SizedBox(height: 12),
            _buildExpandedSummary(
              context,
              feedCount,
              diaperList,
              sleepList,
              genericList,
              customList,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedSummary(
    BuildContext context,
    List<FeedingEntry> feedList,
    List<DiaperEntry> diaperList,
    List<SleepEntry> sleepList,
    List<GenericEntry> genericList,
    List<CustomEntry> customList,
  ) {
    final rows = <Widget>[];

    // Feeding
    if (feedList.isNotEmpty) {
      final totalMl = feedList.fold<int>(
        0,
        (s, e) => s + (e.waterAmountMl ?? 0),
      );
      final totalKcal = feedList.fold<int>(
        0,
        (s, e) => s + (e.foodAmountKcal ?? 0),
      );
      final extra = totalKcal > 0
          ? AppLocalizations.of(context).totalMlKcalLabel(totalMl, totalKcal)
          : AppLocalizations.of(context).totalMlLabel(totalMl);
      rows.add(
        _summaryRow(
          '· ${AppLocalizations.of(context).feedingSummaryLabel}',
          AppLocalizations.of(context).timesLabel(feedList.length),
          extra,
          isParent: true,
        ),
      );

      // 统计喂水和喂食次数
      int waterCount = 0;
      int foodCount = 0;
      for (final e in feedList) {
        if (e.milkSource == '喂水' || e.milkSource == '喂食+喂水') {
          waterCount++;
        }
        if (e.milkSource == '喂食' || e.milkSource == '喂食+喂水') {
          foodCount++;
        }
      }

      if (waterCount > 0) {
        rows.add(
          _summaryRow(
            '  ${AppLocalizations.of(context).breastMilkOption}',
            '$waterCount次',
            '',
            isParent: false,
          ),
        );
      }
      if (foodCount > 0) {
        rows.add(
          _summaryRow(
            '  ${AppLocalizations.of(context).formulaMilkOption}',
            '$foodCount次',
            '',
            isParent: false,
          ),
        );
      }
    }

    // Diaper
    if (diaperList.isNotEmpty) {
      rows.add(
        _summaryRow(
          '· ${AppLocalizations.of(context).diaperSummaryLabel}',
          AppLocalizations.of(context).timesLabel(diaperList.length),
          '',
          isParent: true,
        ),
      );
      final wetCount = diaperList
          .where((e) => e.diaperType == 'wet' || e.diaperType == 'both')
          .length;
      final poopCount = diaperList
          .where((e) => e.diaperType == 'poop' || e.diaperType == 'both')
          .length;
      if (wetCount > 0) {
        rows.add(
          _summaryRow(
            '  ${AppLocalizations.of(context).pee}',
            '$wetCount次',
            '',
            isParent: false,
          ),
        );
      }
      if (poopCount > 0) {
        rows.add(
          _summaryRow(
            '  ${AppLocalizations.of(context).poop}',
            '$poopCount次',
            '',
            isParent: false,
          ),
        );
      }
    }

    // Sleep
    if (sleepList.isNotEmpty) {
      int totalMin = 0;
      for (final e in sleepList) {
        if (e.endTime != null) {
          totalMin += e.endTime!.difference(e.startTime).inMinutes;
        }
      }
      final durStr = totalMin > 0
          ? AppLocalizations.of(context).totalHourMinuteLabel(totalMin ~/ 60, totalMin % 60)
          : '';
      rows.add(
        _summaryRow(
          '· ${AppLocalizations.of(context).sleepSummaryLabel}',
          AppLocalizations.of(context).timesLabel(sleepList.length),
          durStr,
          isParent: true,
        ),
      );
    }

    // Generic types
    for (final t in [
      AppLocalizations.of(context).milestone,
      AppLocalizations.of(context).temperature,
      AppLocalizations.of(context).healing,
      AppLocalizations.of(context).self,
    ]) {
      final list = genericList.where((e) => e.type == t).toList();
      if (list.isNotEmpty) {
        rows.add(_summaryRow('· $t', '${list.length}次', '', isParent: true));
      }
    }

    // Custom
    if (customList.isNotEmpty) {
      final first = customList.first;
      rows.add(
        _summaryRow(
          '· 学与教',
          '${customList.length}次',
          first.eventName.isNotEmpty ? first.eventName : '',
          isParent: true,
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _summaryRow(
    String label,
    String count,
    String extra, {
    required bool isParent,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isParent ? 4 : 2, top: isParent ? 4 : 0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isParent ? 14 : 13,
              color: isParent
                  ? const Color(0xFF333333)
                  : const Color(0xFF999999),
              fontWeight: isParent ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: isParent ? 14 : 13,
              color: isParent
                  ? const Color(0xFF333333)
                  : const Color(0xFF999999),
            ),
          ),
          if (extra.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              extra,
              style: TextStyle(
                fontSize: isParent ? 14 : 13,
                color: isParent
                    ? const Color(0xFF333333)
                    : const Color(0xFF999999),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppEmojis.emptyState,
            style: TextStyle(fontSize: 72, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).noRecords,
            style: const TextStyle(color: Color(0xFF999999), fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).clickToAdd,
            style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Timeline ──────────────────────────────────────────────────────────────

  Widget _buildTimeline(
    BuildContext context,
    List<_Entry> entries,
    AppProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: entries.length,
      itemBuilder: (ctx, i) =>
          _buildTimelineRow(ctx, entries[i], provider, i == entries.length - 1),
    );
  }

  Color _getDotColor(String type, dynamic data) {
    switch (type) {
      case 'generic':
        final e = data as GenericEntry;
        if (e.type == '觉察') return kDotAwareness;
        if (e.type == '运动') return kDotExercise;
        return kDotDefault;
      case 'feeding':
        final e = data as FeedingEntry;
        if (e.milkSource == '喂水') return kDotWater;
        return kDotFeeding;
      case 'diaper':
        return kDotDefault;
      case 'sleep':
        return const Color(0xFFFFB74D);
      case 'custom':
        return kDotDefault;
      case 'med':
        return const Color(0xFFEF5350);
      case 'solidFood':
        return const Color(0xFFFFB74D);
      default:
        return kDotDefault;
    }
  }

  Widget _buildTimelineRow(
    BuildContext context,
    _Entry entry,
    AppProvider provider,
    bool isLast,
  ) {
    final now = DateTime.now();
    final diff = now.difference(entry.timestamp);
    final String ago;
    if (diff.inMinutes < 1) {
      ago = '刚刚';
    } else if (diff.inMinutes < 60) {
      ago = '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      ago = m > 0 ? '${h}小时${m}分钟前' : '${h}小时前';
    } else {
      ago = DateFormat('MM-dd').format(entry.timestamp);
    }

    final dotColor = _getDotColor(entry.type, entry.data);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 68,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(entry.timestamp),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  ago,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Dot + line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withAlpha(60),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFE8E8E8)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCard(context, entry),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _Entry entry) {
    switch (entry.type) {
      case 'feeding':
        final e = entry.data as FeedingEntry;
        final emoji = '🍚';
        final emojiColor = const Color(0xFFFFF3E0);
        String subtitle = '';
        if (e.milkSource == '喂水') {
          subtitle = '${e.amountMl}mL';
        } else if (e.milkSource == '喂食') {
          subtitle = '${e.foodAmountKcal ?? e.amountMl}kcal';
        } else {
          subtitle = '${e.foodAmountKcal ?? 0}kcal';
        }
        return _TimelineCard(
          emoji: emoji,
          emojiColor: emojiColor,
          title: '投喂',
          subtitle: subtitle,
          onTap: () => _goto(FeedingPage(entry: e)),
        );
      case 'diaper':
        final e = entry.data as DiaperEntry;
        return _TimelineCard(
          emoji: '🚽',
          emojiColor: const Color(0xFFE3F2FD),
          title: '解便',
          subtitle: e.typeLabel,
          onTap: () => _goto(DiaperPage(entry: e)),
        );
      case 'sleep':
        final e = entry.data as SleepEntry;
        String subtitle = '';
        if (e.endTime != null) {
          final duration = e.endTime!.difference(e.startTime);
          subtitle = '${duration.inMinutes}分钟';
        }
        return _TimelineCard(
          emoji: '😴',
          emojiColor: const Color(0xFFF3E5F5),
          title: '睡眠',
          subtitle: subtitle.isNotEmpty ? subtitle : null,
          onTap: () => _goto(SleepPage(entry: e)),
        );
      case 'generic':
        final e = entry.data as GenericEntry;
        final icons = {
          '锻炼': ('🏃', const Color(0xFFFFF3E0)),
          '觉察': ('🧘', const Color(0xFFE3F2FD)),
          '疗愈': ('💝', const Color(0xFFFCE4EC)),
          '真我': ('☀️', const Color(0xFFFFF8E1)),
          '睡眠': ('😴', const Color(0xFFF3E5F5)),
        };
        final icon = icons[e.type] ?? (AppEmojis.custom, const Color(0xFFF5F5F5));
        String subtitle = '';
        if (e.endTime != null && e.startTime != null) {
          final duration = e.endTime!.difference(e.startTime);
          subtitle = '${duration.inMinutes}分钟';
        } else if (e.notes != null && e.notes!.isNotEmpty) {
          subtitle = e.notes!;
        }
        return _TimelineCard(
          emoji: icon.$1,
          emojiColor: icon.$2,
          title: e.type,
          subtitle: subtitle.isNotEmpty ? subtitle : null,
          trailing: subtitle.contains('分钟') ? null : null,
          onTap: () => _goto(GenericRecordPage(type: e.type, entry: e)),
        );
      case 'custom':
        final e = entry.data as CustomEntry;
        return _TimelineCard(
          emoji: '📝',
          emojiColor: const Color(0xFFFFF5E0),
          title: e.eventName.isNotEmpty ? e.eventName : '自定义',
          subtitle: e.notes,
          onTap: () => _goto(CustomPage(entry: e)),
        );
      case 'med':
        final e = entry.data as MedEntry;
        return _TimelineCard(
          emoji: '💝',
          emojiColor: const Color(0xFFFCE4EC),
          title: '疗愈',
          subtitle: e.notes,
          onTap: () => _goto(MedicationPage()),
        );
      case 'solidFood':
        final e = entry.data as SolidFoodEntry;
        return _TimelineCard(
          emoji: '🥄',
          emojiColor: const Color(0xFFFFF3E0),
          title: '辅食',
          subtitle: e.notes,
          onTap: () => _goto(SolidFoodPage()),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Bottom bar (2 rows × 4) ───────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomBtn('🍚', '投喂', () => _goto(const FeedingPage())),
                  _BottomBtn('🚽', '解便', () => _goto(const DiaperPage())),
                  _BottomBtn('😴', '睡眠', () => _goto(const SleepPage())),
                  _BottomBtn('🏃', '运动', () => _goto(const GenericRecordPage(type: '运动'))),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomBtn('🧘', '觉察', () => _goto(const GenericRecordPage(type: '觉察'))),
                  _BottomBtn('💝', '疗愈', () => _goto(const GenericRecordPage(type: '疗愈'))),
                  _BottomBtn('☀️', '真我', () => _goto(const GenericRecordPage(type: '真我'))),
                  _BottomBtn('📝', '自定义', () => _goto(const CustomPage())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goto(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

// ─── Timeline card ─────────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final String emoji;
  final Color emojiColor;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  const _TimelineCard({
    required this.emoji,
    required this.emojiColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: emojiColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom action button ──────────────────────────────────────────────────────

class _BottomBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _BottomBtn(this.emoji, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? badge;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  if (badge != null && badge!.isNotEmpty)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withAlpha(40),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF999999),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
