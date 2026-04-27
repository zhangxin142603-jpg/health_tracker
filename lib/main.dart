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
import 'screens/summary_page.dart';
import 'screens/webview_page.dart';

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

// ─── Orb animation data ───────────────────────────────────────────────────────────

class _OrbData {
  final int id;
  final int targetIdx;
  final Offset source;
  final Offset target;
  final Color color;
  _OrbData({
    required this.id,
    required this.targetIdx,
    required this.source,
    required this.target,
    required this.color,
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

  // Orb animation
  final _statKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
  final _stackKey = GlobalKey();
  final _animatedEntryIds = <String>{};
  final _entryDotKeys = <String, GlobalKey>{};
  final _activeOrbs = <_OrbData>[];
  int _nextOrbId = 0;
  final _sweepCounters = [0, 0, 0];
  bool _orbReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _markInitialEntries();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        // Mark again in case data loaded asynchronously after first frame
        _markInitialEntries();
        _orbReady = true;
      });
    });
  }

  void _markInitialEntries() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final entries = _buildEntries(provider);
    for (final entry in entries) {
      if (_matchesAnimationRule(entry)) {
        _animatedEntryIds.add(entry.id);
      }
    }
  }

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

    // Detect new entries for orb animation
    final newEntryIds = <String>{};
    for (final entry in entries) {
      if (_animatedEntryIds.contains(entry.id)) continue;
      if (_matchesAnimationRule(entry)) {
        newEntryIds.add(entry.id);
        _entryDotKeys.putIfAbsent(entry.id, () => GlobalKey());
      }
    }

    if (!_orbReady) {
      // Before first frame: silently mark entries as processed
      _animatedEntryIds.addAll(newEntryIds);
    } else if (newEntryIds.isNotEmpty) {
      _animatedEntryIds.addAll(newEntryIds);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final id in newEntryIds) {
          _startOrbAnimation(id);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        key: _stackKey,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
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
          // Orb overlay
          ..._activeOrbs.map(_buildOrbWidget),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final dateLabel = DateFormat('yyyy.MM.dd').format(_selectedDate);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 8, 18),
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
            const SizedBox(width: 26),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: dateLabel,
                            style: const TextStyle(
                              color: kDateText,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (_isToday())
                            const TextSpan(
                              text: '  今日',
                              style: TextStyle(
                                color: kDateText,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      Provider.of<AppProvider>(context).userMotto,
                      style: const TextStyle(
                        color: kSubtitleText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: kPrimary,
                size: 22,
              ),
              onPressed: _pickDate,
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
          border: Border.all(color: kPrimaryLight, width: 2),
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
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: kPrimaryLight, width: 2),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withAlpha(40),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context).me,
            style: const TextStyle(
              color: kPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  // ─── Stat cards ────────────────────────────────────────────────────────────

  Widget _buildStatCards(AppProvider provider) {
    final healingCount = provider.genericEntries
        .where((e) => e.type == '疗愈')
        .length;
    final customCount = provider.customEntries.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 0),
      child: Row(
        children: [
          _StatCard(
            key: _statKeys[0],
            sweepTrigger: _sweepCounters[0],
            imagePath: 'assets/icons/spt_level.png',
            title: 'SPT熟练度',
            subtitle: '练习提升，核心技能',
            badge: '${healingCount + customCount}',
            onTap: () => _goto(const WebViewPage()),
          ),
          const SizedBox(width: 10),
          _StatCard(
            key: _statKeys[1],
            sweepTrigger: _sweepCounters[1],
            imagePath: 'assets/icons/true_self.png',
            title: '真我显现度',
            subtitle: '展现真我，主线任务',
            imageHeight: 75,
            onTap: () => _goto(WebViewPage(
              url: 'https://tcn8v998v5li.feishu.cn/docx/GmyAd2kXaojNbFx7Djkck6dznYw',
              title: '真我显现度',
            )),
          ),
          const SizedBox(width: 10),
          _StatCard(
            key: _statKeys[2],
            sweepTrigger: _sweepCounters[2],
            imagePath: 'assets/icons/persona.png',
            title: '子人格图鉴',
            subtitle: '疗愈内在，收集系统',
            onTap: () => _goto(const SummaryPage()),
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
          ? AppLocalizations.of(
              context,
            ).totalHourMinuteLabel(totalMin ~/ 60, totalMin % 60)
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
      ago = AppLocalizations.of(context).justNow;
    } else if (diff.inMinutes < 60) {
      ago = AppLocalizations.of(context).minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      ago = m > 0
          ? AppLocalizations.of(context).hoursMinutesAgo(h, m)
          : AppLocalizations.of(context).hoursAgo(h);
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
                decoration: const BoxDecoration(
                  color: Color(0xFF9B8FF9),
                  shape: BoxShape.circle,
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
              padding: const EdgeInsets.only(bottom: 8),
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
          emojiKey: _entryDotKeys[entry.id],
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
          emojiKey: _entryDotKeys[entry.id],
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
            ? AppLocalizations.of(
                context,
              ).sleepEndLabel(DateFormat('HH:mm').format(e.endTime!))
            : '';
        return _TimelineCard(
          emojiKey: _entryDotKeys[entry.id],
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
        final displayNames = {
          '锻炼': '运动',
        };
        return _TimelineCard(
          emojiKey: _entryDotKeys[entry.id],
          emoji: icon.$1,
          emojiColor: icon.$2,
          title: displayNames[e.type] ?? e.type,
          subtitle: e.notes,
          onTap: () => _goto(GenericRecordPage(type: e.type, entry: e)),
        );
      case 'custom':
        final e = entry.data as CustomEntry;
        return _TimelineCard(
          emojiKey: _entryDotKeys[entry.id],
          emoji: AppEmojis.custom,
          emojiColor: const Color(0xFFFFF5E0),
          title: e.eventName.isNotEmpty ? e.eventName : '学与教',
          subtitle: e.notes,
          onTap: () => _goto(CustomPage(entry: e)),
        );
      case 'med':
        final e = entry.data as MedEntry;
        return _TimelineCard(
          emojiKey: _entryDotKeys[entry.id],
          emoji: AppEmojis.healing,
          emojiColor: const Color(0xFFFFEEF0),
          title: '疗愈',
          subtitle: e.notes,
          onTap: () => _goto(MedicationPage()),
        );
      case 'solidFood':
        final e = entry.data as SolidFoodEntry;
        return _TimelineCard(
          emojiKey: _entryDotKeys[entry.id],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: false,
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
                      '运动',
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
      ),
    );
  }

  bool _matchesAnimationRule(_Entry entry) {
    if (entry.type == 'custom') return true;
    if (entry.type == 'feeding' ||
        entry.type == 'diaper' ||
        entry.type == 'sleep') {
      return true;
    }
    if (entry.type == 'generic') {
      final t = (entry.data as GenericEntry).type;
      return t == '觉察' || t == '疗愈' || t == '真我' || t == '锻炼';
    }
    return false;
  }

  List<int> _getStatTargets(_Entry entry) {
    if (entry.type == 'custom') return [0, 1, 2];
    if (entry.type == 'feeding' ||
        entry.type == 'diaper' ||
        entry.type == 'sleep') {
      return [1];
    }
    if (entry.type == 'generic') {
      final t = (entry.data as GenericEntry).type;
      if (t == '锻炼' || t == '觉察' || t == '真我') return [1];
      if (t == '疗愈') return [0, 1, 2];
    }
    return [];
  }

  void _startOrbAnimation(String entryId) {
    final dotKey = _entryDotKeys[entryId];
    if (dotKey?.currentContext == null) return;

    final entry = _findEntryById(entryId);
    if (entry == null) return;

    final targets = _getStatTargets(entry);
    if (targets.isEmpty) return;

    final dotRenderBox =
        dotKey!.currentContext!.findRenderObject() as RenderBox?;
    if (dotRenderBox == null) return;

    final dotCenter = dotRenderBox.localToGlobal(
      Offset(dotRenderBox.size.width / 2, dotRenderBox.size.height / 2),
    );

    final stackRenderBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackRenderBox == null) return;

    final sourceInStack = stackRenderBox.globalToLocal(dotCenter);

    for (final targetIdx in targets) {
      final statKey = _statKeys[targetIdx];
      final statRenderBox =
          statKey.currentContext?.findRenderObject() as RenderBox?;
      if (statRenderBox == null) continue;

      final statCenter = statRenderBox.localToGlobal(
        Offset(statRenderBox.size.width / 2, statRenderBox.size.height / 2),
      );
      final targetInStack = stackRenderBox.globalToLocal(statCenter);

      final orbId = _nextOrbId++;
      final orbColor = kPrimaryLight;

      setState(() {
        _activeOrbs.add(
          _OrbData(
            id: orbId,
            targetIdx: targetIdx,
            source: sourceInStack,
            target: targetInStack,
            color: orbColor,
          ),
        );
      });

      const orbDuration = 1200; // ms

      // Trigger sweep just before orb arrives (at ~80%)
      Future.delayed(Duration(milliseconds: (orbDuration * 0.8).toInt()), () {
        if (!mounted) return;
        _triggerSweep(targetIdx);
      });

      // Remove orb after animation completes
      Future.delayed(Duration(milliseconds: orbDuration + 50), () {
        if (!mounted) return;
        setState(() {
          _activeOrbs.removeWhere((o) => o.id == orbId);
        });
      });
    }
  }

  void _triggerSweep(int targetIdx) {
    if (!mounted) return;
    setState(() {
      _sweepCounters[targetIdx]++;
    });
  }

  _Entry? _findEntryById(String id) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final entries = _buildEntries(provider);
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  Widget _buildOrbWidget(_OrbData data) {
    return Positioned(
      left: 0,
      top: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        builder: (context, progress, child) {
          final currentOffset = Offset.lerp(
            data.source,
            data.target,
            progress,
          )!;
          final opacity = progress < 0.1
              ? progress / 0.1
              : progress > 0.7
              ? (1.0 - progress) / 0.3
              : 1.0;
          return Opacity(
            opacity: opacity,
            child: Transform.translate(offset: currentOffset, child: child),
          );
        },
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kPrimaryLight.withAlpha(180),
                blurRadius: 12,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: kPrimaryLight.withAlpha(100),
                blurRadius: 24,
                spreadRadius: 12,
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
  final Key? emojiKey;

  const _TimelineCard({
    required this.emoji,
    required this.emojiColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.emojiKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              key: emojiKey,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: emojiColor,
                borderRadius: BorderRadius.circular(22),
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

// ─── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final int sweepTrigger;
  final String imagePath;
  final String title;
  final String subtitle;
  final String? badge;
  final double imageHeight;
  final VoidCallback? onTap;
  const _StatCard({
    super.key,
    this.sweepTrigger = 0,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.badge,
    this.imageHeight = 72,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Image.asset(imagePath, height: imageHeight, fit: BoxFit.contain),
                if (sweepTrigger > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('sweep_$sweepTrigger'),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        builder: (context, progress, _) {
                          return CustomPaint(
                            painter: _SweepPainter(progress: progress),
                          );
                        },
                      ),
                    ),
                  ),
                if (badge != null && badge!.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    ),
  );
  }
}

class _SweepPainter extends CustomPainter {
  final double progress;

  _SweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bandPos = progress;
    final bandWidth = 0.3;
    final lightOpacity = (1.0 - progress) * 0.45;

    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(lightOpacity * 0.6),
        Colors.white.withOpacity(lightOpacity),
        Colors.white.withOpacity(lightOpacity * 0.6),
        Colors.white.withOpacity(0),
        Colors.transparent,
      ],
      stops: [
        0.0,
        (bandPos - bandWidth * 0.5).clamp(0.0, 1.0),
        (bandPos - bandWidth * 0.25).clamp(0.0, 1.0),
        bandPos.clamp(0.0, 1.0),
        (bandPos + bandWidth * 0.25).clamp(0.0, 1.0),
        (bandPos + bandWidth * 0.5).clamp(0.0, 1.0),
        1.0,
      ],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.progress != progress;
}
