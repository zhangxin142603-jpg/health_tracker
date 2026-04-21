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
      backgroundColor: kPrimary,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSummaryCard(provider),
                  const SizedBox(height: 8),
                  Expanded(
                    child: entries.isEmpty
                        ? _buildEmpty()
                        : _buildTimeline(context, entries, provider),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, provider),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final label = DateFormat('yyyy.MM.dd').format(_selectedDate);
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            // "我" avatar
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
                child: _buildAvatar(context),
              ),
            ),
            // Date (centered, tappable)
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isToday() ? '今日' : '过往',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Left/Right day navigation
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(provider.userAvatarPath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromARGB(64, 255, 255, 255),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            '我',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }

  // ─── Summary card (expandable) ─────────────────────────────────────────────

  Widget _buildSummaryCard(AppProvider provider) {
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
    for (final t in ['锻炼', '觉察', '疗愈', '真我']) {
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
          ? '共${totalMl}mL / ${totalKcal}kcal'
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
          ? '共${totalMin ~/ 60}小时${totalMin % 60}分钟'
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
    for (final t in ['锻炼', '觉察', '疗愈', '真我']) {
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
      ago = m > 0 ? '$h小时$m分钟前' : '$h小时前';
    } else {
      ago = DateFormat('MM-dd').format(entry.timestamp);
    }

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
                    fontSize: 10,
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
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.5, color: const Color(0xFFE0E0E0)),
                ),
            ],
          ),
          const SizedBox(width: 10),
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
        final emoji = e.milkSource == '喂食'
            ? AppEmojis.food
            : e.milkSource == '喂食+喂水'
            ? AppEmojis.waterAndFood
            : AppEmojis.water;
        final emojiColor = e.milkSource == '喂食'
            ? const Color(0xFFFFF3E0)
            : e.milkSource == '喂食+喂水'
            ? const Color(0xFFF0EEFF)
            : const Color(0xFFE3F0FC);
        return _TimelineCard(
          emoji: emoji,
          emojiColor: emojiColor,
          title: e.milkSource,
          subtitle: e.notes,
          trailing: e.milkSource == '喂食'
              ? '${e.foodAmountKcal ?? e.amountMl}kcal'
              : e.milkSource == '喂食+喂水'
              ? '${e.foodAmountKcal ?? e.amountMl}kcal'
              : '${e.amountMl}mL',
          onTap: () => _goto(FeedingPage(entry: e)),
        );
      case 'diaper':
        final e = entry.data as DiaperEntry;
        final emoji = e.diaperType == 'wet'
            ? AppEmojis.pee
            : e.diaperType == 'poop'
            ? AppEmojis.poop
            : AppEmojis.both;
        return _TimelineCard(
          emoji: emoji,
          emojiColor: e.diaperType == 'wet'
              ? const Color(0xFFE3F0FC)
              : const Color(0xFFFFF3E0),
          title: e.typeLabel,
          subtitle: e.notes,
          onTap: () => _goto(DiaperPage(entry: e)),
        );
      case 'sleep':
        final e = entry.data as SleepEntry;
        final endLabel = e.endTime != null
            ? '(${DateFormat('HH:mm').format(e.endTime!)} 结束）'
            : '';
        return _TimelineCard(
          emoji: AppEmojis.sleep,
          emojiColor: const Color(0xFFFFF8E1),
          title: '睡眠$endLabel',
          subtitle: e.notes,
          trailing: e.durationText,
          onTap: () => _goto(SleepPage(entry: e)),
        );
      case 'generic':
        final e = entry.data as GenericEntry;
        final icons = {
          '锻炼': (AppEmojis.exercise, const Color(0xFFFFEFDF)),
          '觉察': (AppEmojis.awareness, const Color(0xFFE8F8F0)),
          '疗愈': (AppEmojis.healing, const Color(0xFFF0EEFF)),
          '真我': (AppEmojis.self, const Color(0xFFFFEEF0)),
          '睡眠': (AppEmojis.sleep, const Color(0xFFFFF8E1)),
        };
        final icon =
            icons[e.type] ?? (AppEmojis.custom, const Color(0xFFF5F5F5));
        return _TimelineCard(
          emoji: icon.$1,
          emojiColor: icon.$2,
          title: e.type,
          subtitle: e.notes,
          onTap: () => _goto(GenericRecordPage(type: e.type, entry: e)),
        );
      case 'custom':
        final e = entry.data as CustomEntry;
        return _TimelineCard(
          emoji: AppEmojis.custom,
          emojiColor: const Color(0xFFFFF5E0),
          title: e.eventName.isNotEmpty ? e.eventName : '学与教',
          subtitle: e.notes,
          onTap: () => _goto(CustomPage(entry: e)),
        );
      case 'med':
        final e = entry.data as MedEntry;
        return _TimelineCard(
          emoji: AppEmojis.healing,
          emojiColor: const Color(0xFFFFEEF0),
          title: '疗愈',
          subtitle: e.notes,
          onTap: () => _goto(MedicationPage()),
        );
      case 'solidFood':
        final e = entry.data as SolidFoodEntry;
        return _TimelineCard(
          emoji: AppEmojis.spoon,
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
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(15, 0, 0, 0),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomBtn(
                    AppEmojis.feeding,
                    '投喂',
                    const Color(0xFF5B9BD5),
                    () => _goto(const FeedingPage()),
                  ),
                  _BottomBtn(
                    AppEmojis.diaper,
                    '解便',
                    const Color(0xFF5B9BD5),
                    () => _goto(const DiaperPage()),
                  ),
                  _BottomBtn(
                    AppEmojis.sleep,
                    '睡眠',
                    const Color(0xFFE8A020),
                    () => _goto(const SleepPage()),
                  ),
                  _BottomBtn(
                    AppEmojis.exercise,
                    '锻炼',
                    const Color(0xFF9B8FF9),
                    () => _goto(const GenericRecordPage(type: '锻炼')),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Row 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomBtn(
                    AppEmojis.awareness,
                    '觉察',
                    const Color(0xFF3DB070),
                    () => _goto(const GenericRecordPage(type: '觉察')),
                  ),
                  _BottomBtn(
                    AppEmojis.healing,
                    '疗愈',
                    const Color(0xFF7B9BD5),
                    () => _goto(const GenericRecordPage(type: '疗愈')),
                  ),
                  _BottomBtn(
                    AppEmojis.self,
                    '真我',
                    const Color(0xFF3DB070),
                    () => _goto(const GenericRecordPage(type: '真我')),
                  ),
                  _BottomBtn(
                    AppEmojis.custom,
                    '学与教',
                    const Color(0xFFE8A020),
                    () => _goto(const CustomPage()),
                  ),
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
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(10, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: emojiColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
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
                      color: Color(0xFF222222),
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailing != null && trailing!.isNotEmpty)
              Text(
                trailing!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
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
  final Color color;
  final VoidCallback onTap;

  const _BottomBtn(this.emoji, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
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
