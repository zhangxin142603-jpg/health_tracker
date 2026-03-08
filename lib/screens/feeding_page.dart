import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

const Color _kPurple = Color(0xFF7B6CF6);

class FeedingPage extends StatefulWidget {
  final FeedingEntry? entry; // non-null = edit mode

  const FeedingPage({super.key, this.entry});

  @override
  State<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage> {
  late DateTime _startTime;
  DateTime? _endTime;
  late int _amount;
  late String _milkSource; // '喂水' | '喂食' | '喂食+喂水'
  late final TextEditingController _notesCtrl;

  bool get _isEdit => widget.entry != null;

  static const _milkSources = [
    _MilkOption('喂水', Color(0xFF4CAF50)),
    _MilkOption('喂食', Color(0xFFFF9800)),
    _MilkOption('喂食+喂水', Color(0xFF5B9BD5)),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _startTime = widget.entry!.timestamp;
      _endTime = null;
      _amount = widget.entry!.amountMl;
      _milkSource = '喂水';
      _notesCtrl = TextEditingController(text: widget.entry!.notes ?? '');
    } else {
      _startTime = DateTime.now();
      _endTime = null;
      _amount = 250;
      _milkSource = '喂水';
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
                  _milkSourceSection(),
                  const SizedBox(height: 10),
                  _sectionCard([_amountRow()]),
                  const SizedBox(height: 10),
                  _notesSection(),
                  const SizedBox(height: 10),
                  _photoSection(),
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
        title: Text(AppLocalizations.of(context).feedingPageTitle,
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

  Widget _milkSourceSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).milkSourceLabel,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            Row(
              children: _milkSources
                  .map((opt) => Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: _milkSourceOption(opt),
                      ))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _milkSourceOption(_MilkOption opt) {
    final selected = _milkSource == opt.label;
    return GestureDetector(
      onTap: () => setState(() => _milkSource = opt.label),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? const Color(0xFFFFF0F0) : opt.color,
              border: Border.all(
                color: selected ? Colors.pinkAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: opt.color.withOpacity(0.7),
                        ),
                      ),
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
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(opt.label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF555555))),
        ],
      ),
    );
  }

  Widget _amountRow() => InkWell(
        onTap: _pickAmount,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(AppLocalizations.of(context).milkAmountLabel,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
              const Spacer(),
              Text('$_amount mL',
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF999999))),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFCCCCCC), size: 20),
            ],
          ),
        ),
      );

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
              maxLength: 200,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).feedingNotesHint,
                hintStyle:
                    const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                border: InputBorder.none,
                counterStyle: TextStyle(color: Color(0xFFBBBBBB)),
              ),
            ),
          ],
        ),
      );

  Widget _photoSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: GestureDetector(
          onTap: () {}, // placeholder for photo picker
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline,
                    size: 28, color: Color(0xFF999999)),
                SizedBox(height: 6),
                Text('上传照片',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
          ),
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

  Future<void> _pickAmount() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _AmountDialog(initial: _amount),
    );
    if (result != null) setState(() => _amount = result);
  }

  void _save() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final entry = FeedingEntry(
      id: _isEdit
          ? widget.entry!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: _startTime,
      amountMl: _amount,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (_isEdit) {
      provider.removeEntry('feeding', widget.entry!.id);
      provider.addFeeding(entry);
    } else {
      provider.addFeeding(entry);
    }
    Navigator.pop(context);
  }

  void _delete() {
    Provider.of<AppProvider>(context, listen: false)
        .removeEntry('feeding', widget.entry!.id);
    Navigator.pop(context);
  }
}

class _MilkOption {
  final String label;
  final Color color;
  const _MilkOption(this.label, this.color);
}

class _AmountDialog extends StatefulWidget {
  final int initial;
  const _AmountDialog({required this.initial});

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final _ctrl = TextEditingController(text: widget.initial.toString());
  final _presets = [60, 90, 120, 150, 180, 210, 240, 270, 300, 400, 500];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cur = int.tryParse(_ctrl.text) ?? widget.initial;
    return AlertDialog(
      title: const Text('水量选择'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final sel = cur == p;
              return GestureDetector(
                onTap: () => setState(() => _ctrl.text = p.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? _kPurple.withOpacity(0.1)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _kPurple : Colors.transparent),
                  ),
                  child: Text(
                    '$p mL',
                    style: TextStyle(
                      color: sel ? _kPurple : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: '自定义 mL',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple, foregroundColor: Colors.white),
          onPressed: () {
            final v = int.tryParse(_ctrl.text);
            if (v != null && v > 0) Navigator.pop(context, v);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
