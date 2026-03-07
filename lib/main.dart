import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/app_provider.dart';
import 'models/baby_entries.dart';
import 'screens/feeding_page.dart';
import 'screens/medication_page.dart';
import 'screens/diaper_page.dart';
import 'screens/solid_food_page.dart';
import 'screens/sleep_page.dart';
import 'l10n/strings.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const BabyTrackerApp());
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
        title: AppStrings.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
          useMaterial3: true,
          fontFamily: 'PingFang SC',
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ─── Timeline entry (unified) ─────────────────────────────────────────────────

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

// ─── Home Page ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  String _filter = AppStrings.all; // '全部' | 'feeding' | 'med' | 'diaper' | 'solidFood' | 'sleep'

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  bool _sameDay(DateTime dt) =>
      dt.year == _selectedDate.year &&
      dt.month == _selectedDate.month &&
      dt.day == _selectedDate.day;

  List<_Entry> _buildEntries(AppProvider p) {
    final all = <_Entry>[
      ...p.feedingEntries
          .where((e) => _sameDay(e.timestamp))
          .map((e) =>
              _Entry(timestamp: e.timestamp, type: 'feeding', id: e.id, data: e)),
      ...p.medEntries
          .where((e) => _sameDay(e.timestamp))
          .map((e) =>
              _Entry(timestamp: e.timestamp, type: 'med', id: e.id, data: e)),
      ...p.diaperEntries
          .where((e) => _sameDay(e.timestamp))
          .map((e) =>
              _Entry(timestamp: e.timestamp, type: 'diaper', id: e.id, data: e)),
      ...p.solidFoodEntries
          .where((e) => _sameDay(e.timestamp))
          .map((e) => _Entry(
              timestamp: e.timestamp, type: 'solidFood', id: e.id, data: e)),
      ...p.sleepEntries
          .where((e) => _sameDay(e.startTime))
          .map((e) => _Entry(
              timestamp: e.startTime, type: 'sleep', id: e.id, data: e)),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (_filter == AppStrings.all) return all;
    return all.where((e) => e.type == _filter).toList();
  }

  void _prevDay() =>
      setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));

  void _nextDay() {
    final next = _selectedDate.add(const Duration(days: 1));
    if (!next.isAfter(DateTime.now())) {
      setState(() => _selectedDate = next);
    }
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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildFilterBar(provider),
                  _buildSummaryBar(context, provider),
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

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final label = DateFormat('yyyy.MM.dd').format(_selectedDate);
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: _prevDay,
            ),
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
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white70, size: 22),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined,
                  color: Colors.white, size: 22),
              onPressed: _pickDate,
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded,
                  color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filter bar ──────────────────────────────────────────────────────────

  Widget _buildFilterBar(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          _filterDropdown(),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF07C160).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.people_outline,
                    color: Color(0xFF07C160), size: 16),
                SizedBox(width: 4),
                Text(AppStrings.inviteFriends,
                    style: TextStyle(
                        color: Color(0xFF07C160),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown() {
    const options = <String, String>{
      '全部': AppStrings.all,
      'feeding': AppStrings.feeding,
      'med': AppStrings.medication,
      'diaper': AppStrings.diaper,
      'solidFood': AppStrings.solidFood,
      'sleep': AppStrings.sleep,
    };
    final label = options[_filter] ?? AppStrings.all;

    return GestureDetector(
      onTap: () async {
        final entry = await showMenu<String>(
          context: context,
          position: const RelativeRect.fromLTRB(16, 120, 0, 0),
          items: options.entries
              .map((e) => PopupMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
        );
        if (entry != null) setState(() => _filter = entry);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }

  // ─── Summary bar ─────────────────────────────────────────────────────────

  Widget _buildSummaryBar(BuildContext context, AppProvider provider) {
    final feedCount = provider.feedingEntries.where((e) => _sameDay(e.timestamp)).length;
    final medCount = provider.medEntries.where((e) => _sameDay(e.timestamp)).length;
    final diaperCount = provider.diaperEntries.where((e) => _sameDay(e.timestamp)).length;
    final solidCount = provider.solidFoodEntries.where((e) => _sameDay(e.timestamp)).length;
    final sleepCount = provider.sleepEntries.where((e) => _sameDay(e.startTime)).length;

    final parts = <String>[];
    if (feedCount > 0) parts.add(AppLocalizations.of(context).feedingCount(feedCount));
    if (medCount > 0) parts.add(AppLocalizations.of(context).medicationCount(medCount));
    if (diaperCount > 0) parts.add(AppLocalizations.of(context).diaperCount(diaperCount));
    if (solidCount > 0) parts.add(AppLocalizations.of(context).solidFoodCount(solidCount));
    if (sleepCount > 0) parts.add(AppLocalizations.of(context).sleepCount(sleepCount));

    final text = parts.isEmpty ? AppStrings.todayNoRecords : '· ${parts.join(' · ')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👶',
              style: TextStyle(
                  fontSize: 72, color: Colors.grey.shade300)),
          const SizedBox(height: 12),
          const Text(AppStrings.noRecords,
              style: TextStyle(color: Color(0xFF999999), fontSize: 16)),
          const SizedBox(height: 6),
          const Text(AppStrings.clickToAdd,
              style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Timeline ────────────────────────────────────────────────────────────

  Widget _buildTimeline(BuildContext context, List<_Entry> entries, AppProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: entries.length,
      itemBuilder: (ctx, i) =>
          _buildTimelineRow(ctx, entries[i], provider, i == entries.length - 1),
    );
  }

  Widget _buildTimelineRow(
      BuildContext context, _Entry entry, AppProvider provider, bool isLast) {
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
      ago = m > 0 ? AppLocalizations.of(context).hoursMinutesAgo(h, m) : AppLocalizations.of(context).hoursAgo(h);
    } else {
      ago = DateFormat('MM-dd').format(entry.timestamp);
    }

    return Dismissible(
      key: Key('${entry.type}_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20, bottom: 12),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
      ),
      onDismissed: (_) => provider.removeEntry(entry.type, entry.id),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 66,
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
                        fontSize: 10, color: Color(0xFFAAAAAA)),
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
                    border: Border.all(
                        color: const Color(0xFFCCCCCC), width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                        width: 1.5,
                        color: const Color(0xFFE0E0E0)),
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
      ),
    );
  }

  Widget _buildCard(BuildContext context, _Entry entry) {
    switch (entry.type) {
      case 'feeding':
        final e = entry.data as FeedingEntry;
        return _TimelineCard(
          emoji: '🍼',
          emojiColor: const Color(0xFFE3F0FC),
          title: AppLocalizations.of(context).feeding,
          trailing: '${e.amountMl}mL',
        );
      case 'med':
        final e = entry.data as MedEntry;
        return _TimelineCard(
          emoji: '💊',
          emojiColor: const Color(0xFFF0EEFF),
          title: AppLocalizations.of(context).medication,
          subtitle: e.medicines.isEmpty ? null : e.medicines.join('、'),
        );
      case 'diaper':
        final e = entry.data as DiaperEntry;
        final isDry = e.diaperType == 'wet';
        return _TimelineCard(
          emoji: isDry ? '💧' : '💩',
          emojiColor: isDry
              ? const Color(0xFFE3F0FC)
              : const Color(0xFFFFF3E0),
          title: e.typeLabel,
        );
      case 'solidFood':
        final e = entry.data as SolidFoodEntry;
        return _TimelineCard(
          emoji: '🥣',
          emojiColor: const Color(0xFFFFEEF0),
          title: AppLocalizations.of(context).solidFood,
          subtitle: e.texture,
        );
      case 'sleep':
        final e = entry.data as SleepEntry;
        return _TimelineCard(
          emoji: '🌙',
          emojiColor: const Color(0xFFFFF8E1),
          title: AppLocalizations.of(context).sleep,
          trailing: e.durationText,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Bottom bar ──────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            GestureDetector(
              onTap: () => _showAllActionsSheet(provider),
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null &&
                    d.primaryVelocity! < -200) {
                  _showAllActionsSheet(provider);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // 4 main actions
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomActionBtn(
                    emoji: '🍼',
                    label: AppLocalizations.of(context).feeding,
                    color: const Color(0xFF5B9BD5),
                    onTap: () => _goto(const FeedingPage()),
                  ),
                  _BottomActionBtn(
                    emoji: '💊',
                    label: AppLocalizations.of(context).medication,
                    color: const Color(0xFF9B8FF9),
                    onTap: () => _goto(const MedicationPage()),
                  ),
                  _BottomActionBtn(
                    emoji: '👶',
                    label: AppLocalizations.of(context).diaper,
                    color: const Color(0xFF5B9BD5),
                    onTap: () => _goto(const DiaperPage()),
                  ),
                  _BottomActionBtn(
                    emoji: '🥣',
                    label: AppLocalizations.of(context).solidFood,
                    color: const Color(0xFFE57A8A),
                    onTap: () => _goto(const SolidFoodPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goto(Widget page) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => page));
  }

  void _showAllActionsSheet(AppProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AllActionsSheet(
        onSelect: (type) {
          Navigator.pop(context);
          switch (type) {
            case 'feeding':
              _goto(const FeedingPage());
              break;
            case 'med':
              _goto(const MedicationPage());
              break;
            case 'diaper':
              _goto(const DiaperPage());
              break;
            case 'solidFood':
              _goto(const SolidFoodPage());
              break;
            case 'sleep':
              _goto(const SleepPage());
              break;
          }
        },
      ),
    );
  }
}

// ─── Timeline card ───────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final String emoji;
  final Color emojiColor;
  final String title;
  final String? subtitle;
  final String? trailing;

  const _TimelineCard({
    required this.emoji,
    required this.emojiColor,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              child: Text(emoji,
                  style: const TextStyle(fontSize: 24)),
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
                        fontSize: 12, color: Color(0xFFAAAAAA)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null && trailing!.isNotEmpty)
            Text(trailing!,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF999999))),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right,
              size: 18, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }
}

// ─── Bottom action button ─────────────────────────────────────────────────────

class _BottomActionBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomActionBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── All actions bottom sheet ─────────────────────────────────────────────────

class _AllActionsSheet extends StatelessWidget {
  final void Function(String type) onSelect;

  const _AllActionsSheet({required this.onSelect});

  static const _actions = [
    _ActionItem('feeding', '🍼', AppStrings.feeding, Color(0xFFE3F0FC)),
    _ActionItem('med', '💊', AppStrings.medication, Color(0xFFF0EEFF)),
    _ActionItem('diaper', '👶', AppStrings.diaper, Color(0xFFE3F0FC)),
    _ActionItem('solidFood', '🥣', AppStrings.solidFood, Color(0xFFFFEEF0)),
    _ActionItem('milestone', '🚩', AppStrings.milestone, Color(0xFFFFEFDF)),
    _ActionItem('sleep', '🌙', AppStrings.sleep, Color(0xFFFFF8E1)),
    _ActionItem('formula', '🍼', AppStrings.formula, Color(0xFFE8F8F0)),
    _ActionItem('pump', '🤱', AppStrings.pump, Color(0xFFFFEEF0)),
    _ActionItem('temp', '🌡️', AppStrings.temperature, Color(0xFFE8F8F0)),
    _ActionItem('breastfeed', '🤱', AppStrings.breastfeed, Color(0xFFFFEEF0)),
    _ActionItem('custom', '✏️', AppStrings.custom, Color(0xFFF5F5F5)),
  ];

  static const _navigableTypes = {
    'feeding', 'med', 'diaper', 'solidFood', 'sleep'
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _actions.length,
              itemBuilder: (_, i) {
                final a = _actions[i];
                return GestureDetector(
                  onTap: () {
                    if (_navigableTypes.contains(a.type)) {
                      onSelect(a.type);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: a.bgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(a.emoji,
                              style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(a.label,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF444444)),
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom buttons
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE)))),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.swap_vert,
                        size: 16, color: Color(0xFF666666)),
                    label: const Text(AppStrings.customSort,
                        style: TextStyle(
                            color: Color(0xFF666666), fontSize: 14)),
                  ),
                ),
                Container(
                    width: 0.5, height: 36, color: const Color(0xFFEEEEEE)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.add,
                        size: 16, color: Color(0xFF666666)),
                    label: const Text(AppStrings.addToHome,
                        style: TextStyle(
                            color: Color(0xFF666666), fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String type;
  final String emoji;
  final String label;
  final Color bgColor;

  const _ActionItem(this.type, this.emoji, this.label, this.bgColor);
}
