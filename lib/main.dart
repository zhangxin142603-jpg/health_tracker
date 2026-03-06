import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/health_provider.dart';
import 'models/water_entry.dart';
import 'models/medication_entry.dart';

void main() {
  runApp(const HealthTrackerApp());
}

const Color kPrimary = Color(0xFF7C6FF7);
const Color kPrimaryLight = Color(0xFF9B8FF9);

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HealthProvider(),
      child: MaterialApp(
        title: '健康记录',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
          useMaterial3: true,
        ),
        home: const HealthTrackerHome(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _TimelineItem {
  final DateTime timestamp;
  final String type; // 'water' | 'medication'
  final dynamic data;
  _TimelineItem({required this.timestamp, required this.type, required this.data});
}

class HealthTrackerHome extends StatefulWidget {
  const HealthTrackerHome({super.key});

  @override
  State<HealthTrackerHome> createState() => _HealthTrackerHomeState();
}

class _HealthTrackerHomeState extends State<HealthTrackerHome> {
  DateTime _selectedDate = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _prevDay() => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  void _nextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    if (!tomorrow.isAfter(DateTime.now())) {
      setState(() => _selectedDate = tomorrow);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    final waterToday = provider.waterEntries.where((e) => _sameDay(e.timestamp)).toList();
    final medToday = provider.medicationEntries.where((e) => _sameDay(e.timestamp)).toList();

    final items = <_TimelineItem>[
      ...waterToday.map((e) => _TimelineItem(timestamp: e.timestamp, type: 'water', data: e)),
      ...medToday.map((e) => _TimelineItem(timestamp: e.timestamp, type: 'medication', data: e)),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _buildHeader(),
          _buildSummary(waterToday.length, medToday.length),
          Expanded(
            child: items.isEmpty
                ? _buildEmpty()
                : _buildTimeline(items, provider),
          ),
          _buildBottomBar(provider),
        ],
      ),
    );
  }

  bool _sameDay(DateTime dt) =>
      dt.year == _selectedDate.year &&
      dt.month == _selectedDate.month &&
      dt.day == _selectedDate.day;

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final label = _isToday
        ? '今天  ${DateFormat('yyyy.MM.dd').format(_selectedDate)}'
        : DateFormat('yyyy.MM.dd').format(_selectedDate);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 22),
                onPressed: _pickDate,
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Summary row ───────────────────────────────────────────────────────────

  Widget _buildSummary(int waterCount, int medCount) {
    final parts = <String>[];
    if (waterCount > 0) parts.add('喝水 $waterCount 次');
    if (medCount > 0) parts.add('吃药 $medCount 次');
    final text = parts.isEmpty ? '今日暂无记录' : '· ${parts.join(' · ')}';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
      ),
    );
  }

  // ─── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('还没有记录', style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('点击下方按钮添加', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Timeline ──────────────────────────────────────────────────────────────

  Widget _buildTimeline(List<_TimelineItem> items, HealthProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildRow(items[i], provider, isLast: i == items.length - 1),
    );
  }

  Widget _buildRow(_TimelineItem item, HealthProvider provider, {required bool isLast}) {
    final now = DateTime.now();
    final diff = now.difference(item.timestamp);
    final String ago;
    if (diff.inMinutes < 1) {
      ago = '刚刚';
    } else if (diff.inMinutes < 60) {
      ago = '${diff.inMinutes} 分钟前';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      ago = m > 0 ? '$h 小时 $m 分钟前' : '$h 小时前';
    } else {
      ago = DateFormat('MM-dd').format(item.timestamp);
    }

    return Dismissible(
      key: Key(item.type == 'water'
          ? (item.data as WaterEntry).id
          : (item.data as MedicationEntry).id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20, bottom: 12),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
      ),
      onDismissed: (_) {
        if (item.type == 'water') {
          provider.removeWaterEntry((item.data as WaterEntry).id);
        } else {
          provider.removeMedicationEntry((item.data as MedicationEntry).id);
        }
      },
      child: IntrinsicHeight(
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
                    DateFormat('HH:mm').format(item.timestamp),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    ago,
                    style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
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
                child: _buildCard(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_TimelineItem item) {
    if (item.type == 'water') {
      final e = item.data as WaterEntry;
      return _EventCard(
        iconData: Icons.water_drop_outlined,
        iconColor: const Color(0xFF5B9BD5),
        iconBg: const Color(0xFFE8F3FC),
        title: '喝水',
        trailing: '${e.amount} mL',
      );
    } else {
      final e = item.data as MedicationEntry;
      return _EventCard(
        iconData: Icons.medication_outlined,
        iconColor: const Color(0xFF7B68EE),
        iconBg: const Color(0xFFF0EEFF),
        title: e.name,
        subtitle: e.dosage,
        trailing: e.notes,
      );
    }
  }

  // ─── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(HealthProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomAction(
                icon: Icons.water_drop_outlined,
                label: '喝水',
                color: const Color(0xFF5B9BD5),
                onTap: () => _showWaterSheet(provider),
              ),
              _BottomAction(
                icon: Icons.medication_outlined,
                label: '吃药',
                color: const Color(0xFF7B68EE),
                onTap: () => _showMedicationSheet(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom sheets ─────────────────────────────────────────────────────────

  void _showWaterSheet(HealthProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WaterSheet(provider: provider),
    );
  }

  void _showMedicationSheet(HealthProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MedicationSheet(provider: provider),
    );
  }
}

// ─── Event Card ──────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final String? trailing;

  const _EventCard({
    required this.iconData,
    required this.iconColor,
    required this.iconBg,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
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
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }
}

// ─── Bottom action button ─────────────────────────────────────────────────────

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Water bottom sheet ───────────────────────────────────────────────────────

class _WaterSheet extends StatefulWidget {
  final HealthProvider provider;
  const _WaterSheet({required this.provider});

  @override
  State<_WaterSheet> createState() => _WaterSheetState();
}

class _WaterSheetState extends State<_WaterSheet> {
  final _controller = TextEditingController(text: '250');
  final _presets = [100, 200, 250, 300, 500];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '记录喝水',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                final selected = _controller.text == p.toString();
                return GestureDetector(
                  onTap: () => setState(() => _controller.text = p.toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF5B9BD5).withOpacity(0.15)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? const Color(0xFF5B9BD5) : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      '$p mL',
                      style: TextStyle(
                        color: selected ? const Color(0xFF5B9BD5) : const Color(0xFF555555),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '自定义水量 (mL)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final amount = int.tryParse(_controller.text);
                  if (amount != null && amount > 0) {
                    widget.provider.addWaterEntry(amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('确认记录', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Medication bottom sheet ──────────────────────────────────────────────────

class _MedicationSheet extends StatefulWidget {
  final HealthProvider provider;
  const _MedicationSheet({required this.provider});

  @override
  State<_MedicationSheet> createState() => _MedicationSheetState();
}

class _MedicationSheetState extends State<_MedicationSheet> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '记录吃药',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: '药物名称',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosage,
              decoration: InputDecoration(
                labelText: '剂量（如：1片、10mL）',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B68EE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final name = _name.text.trim();
                  final dosage = _dosage.text.trim();
                  if (name.isNotEmpty && dosage.isNotEmpty) {
                    widget.provider.addMedicationEntry(
                      name,
                      dosage,
                      notes: _notes.text.trim().isNotEmpty ? _notes.text.trim() : null,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('确认记录', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
