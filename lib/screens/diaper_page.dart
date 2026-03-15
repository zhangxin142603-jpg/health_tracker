import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../constants/emojis.dart';

const Color _kPurple = Color(0xFF7B6CF6);

class DiaperPage extends StatefulWidget {
  final DiaperEntry? entry; // non-null = edit mode

  const DiaperPage({super.key, this.entry});

  @override
  State<DiaperPage> createState() => _DiaperPageState();
}

class _DiaperPageState extends State<DiaperPage> {
  late DateTime _startTime;
  DateTime? _endTime;
  late String _diaperType;
  late final TextEditingController _notesCtrl;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _startTime = widget.entry!.timestamp;
      _endTime = null;
      _diaperType = widget.entry!.diaperType;
      _notesCtrl = TextEditingController(text: widget.entry!.notes ?? '');
    } else {
      _startTime = DateTime.now();
      _endTime = null;
      _diaperType = 'wet';
      _notesCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime? dt) {
    if (dt == null) return '日期';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '今天';
    }
    return DateFormat('MM-dd').format(dt);
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '时间';
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _sectionCard([
                    _timeRow('开始时间', _startTime, _pickStartDate,
                        _pickStartTime, false),
                    _divider(),
                    _timeRow(
                        '结束时间', _endTime, _pickEndDate, _pickEndTime, true),
                  ]),
                  const SizedBox(height: 10),
                  _diaperTypeSection(),
                  const SizedBox(height: 10),
                  _notesSection(),
                ],
              ),
            ),
          ),
          _saveBtn(),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(AppLocalizations.of(context).diaperPageTitle,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFDDDDDD)),
        ),
      );

  Widget _sectionCard(List<Widget> children) =>
      Container(color: Colors.white, child: Column(children: children));

  Widget _divider() =>
      const Divider(height: 0.5, thickness: 0.5, indent: 16);

  Widget _timeRow(String label, DateTime? dt, VoidCallback onDateTap,
      VoidCallback onTimeTap, bool isEnd) {
    final hasValue = dt != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
          const Spacer(),
          _pillBtn(_dateLabel(dt),
              isTime: false, isEmpty: isEnd && !hasValue, onTap: onDateTap),
          const SizedBox(width: 8),
          _pillBtn(_timeLabel(dt),
              isTime: true, isEmpty: isEnd && !hasValue, onTap: onTimeTap),
        ],
      ),
    );
  }

  Widget _pillBtn(String text,
          {required bool isTime,
          bool isEmpty = false,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text,
              style: TextStyle(
                fontSize: 15,
                color: isEmpty
                    ? const Color(0xFFBBBBBB)
                    : (isTime ? _kPurple : const Color(0xFF555555)),
                fontWeight:
                    (!isEmpty && isTime) ? FontWeight.w500 : FontWeight.normal,
              )),
        ),
      );

  Widget _diaperTypeSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).diaperStatusLabel,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            Row(
              children: [
                _diaperOption('wet', AppEmojis.pee, AppLocalizations.of(context).pee),
                const SizedBox(width: 24),
                _diaperOption('poop', AppEmojis.poop, AppLocalizations.of(context).poop),
                const SizedBox(width: 24),
                _diaperOption('both', AppEmojis.both, AppLocalizations.of(context).poopPee),
              ],
            ),
          ],
        ),
      );

  Widget _diaperOption(String type, String emoji, String label) {
    final selected = _diaperType == type;
    return GestureDetector(
      onTap: () => setState(() => _diaperType = type),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0xFFFFF0F0)
                  : const Color(0xFFF5F5F5),
              border: Border.all(
                color: selected ? Colors.pinkAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                if (selected)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 13, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF555555))),
        ],
      ),
    );
  }

  Widget _notesSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).notes,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).diaperNotesHint,
                hintStyle:
                    const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                border: InputBorder.none,
                counterStyle: TextStyle(color: Color(0xFFBBBBBB)),
              ),
            ),
          ],
        ),
      );


  Widget _saveBtn() => Container(
        color: const Color(0xFFF5F5F5),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                onPressed: _save,
                child: const Text('保存',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w500)),
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _delete,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 16, color: Color(0xFF888888)),
                    SizedBox(width: 4),
                    Text('删除这条记录',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF888888))),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Future<void> _pickStartDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (p != null) {
      setState(() => _startTime = DateTime(
          p.year, p.month, p.day, _startTime.hour, _startTime.minute));
    }
  }

  Future<void> _pickStartTime() async {
    final p = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime));
    if (p != null) {
      setState(() => _startTime = DateTime(
          _startTime.year, _startTime.month, _startTime.day, p.hour, p.minute));
    }
  }

  Future<void> _pickEndDate() async {
    final initial = _endTime ?? DateTime.now();
    final p = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (p != null) {
      final prev = _endTime ?? DateTime.now();
      setState(() => _endTime =
          DateTime(p.year, p.month, p.day, prev.hour, prev.minute));
    }
  }

  Future<void> _pickEndTime() async {
    final initial = _endTime ?? DateTime.now();
    final p = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (p != null) {
      final prev = _endTime ?? DateTime.now();
      setState(() => _endTime =
          DateTime(prev.year, prev.month, prev.day, p.hour, p.minute));
    }
  }

  void _save() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final entry = DiaperEntry(
      id: _isEdit
          ? widget.entry!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: _startTime,
      diaperType: _diaperType,
      symptoms: const [],
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (_isEdit) {
      // For diaper, no update method yet — remove + add
      provider.removeEntry('diaper', widget.entry!.id);
      provider.addDiaper(entry);
    } else {
      provider.addDiaper(entry);
    }
    Navigator.pop(context);
  }

  void _delete() {
    Provider.of<AppProvider>(context, listen: false)
        .removeEntry('diaper', widget.entry!.id);
    Navigator.pop(context);
  }
}
