import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

const Color _kPurple = Color(0xFF7B6CF6);

class GenericRecordPage extends StatefulWidget {
  final String type;
  final GenericEntry? entry; // non-null = edit mode

  const GenericRecordPage({super.key, required this.type, this.entry});

  @override
  State<GenericRecordPage> createState() => _GenericRecordPageState();
}

class _GenericRecordPageState extends State<GenericRecordPage> {
  late DateTime _startTime;
  DateTime? _endTime;
  late final TextEditingController _notesCtrl;
  int? _selectedScore;
  String? _selectedHealingType;

  bool get _isEdit => widget.entry != null;

  static const _scorePattern = r'^(?:10|[6-9])分\s?';

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _startTime = widget.entry!.startTime;
      _endTime = widget.entry!.endTime;
      _notesCtrl = TextEditingController(text: widget.entry!.notes ?? '');
      _selectedScore = widget.entry!.statusScore;
      _selectedHealingType = widget.entry!.healingType;
    } else {
      _startTime = DateTime.now();
      _endTime = null;
      _notesCtrl = TextEditingController();
      _selectedScore = null;
      _selectedHealingType = null;
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
                    _timeRow('结束时间', _endTime, _pickEndDate, _pickEndTime,
                        true),
                  ]),
                  const SizedBox(height: 10),
                  if (widget.type == '觉察') _buildScoreSection(),
                  if (widget.type == '觉察') const SizedBox(height: 10),
                  if (widget.type == '疗愈') _buildHealingTypeSection(),
                  if (widget.type == '疗愈') const SizedBox(height: 10),
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
        title: Text('${widget.type}记录',
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

  Widget _buildScoreSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text('状态评分',
                style: TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: ['10分', '9分', '8分', '7分', '6分'].map((s) {
                  final scoreVal = int.parse(s.replaceAll('分', ''));
                  final selected = _selectedScore == scoreVal;
                  return GestureDetector(
                    onTap: () => _onScoreTap(scoreVal),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? _kPurple : const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF555555),
                          fontWeight:
                              selected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );

  void _onScoreTap(int score) {
    setState(() {
      if (_selectedScore == score) {
        _selectedScore = null;
        _removeScoreFromNotes();
      } else {
        _selectedScore = score;
        _applyScoreToNotes();
      }
    });
  }

  void _applyScoreToNotes() {
    var t = _notesCtrl.text;
    t = t.replaceFirst(RegExp(_scorePattern), '');
    _notesCtrl.text = '$_selectedScore分 $t';
    _notesCtrl.selection =
        TextSelection.collapsed(offset: _notesCtrl.text.length);
  }

  void _removeScoreFromNotes() {
    var t = _notesCtrl.text;
    t = t.replaceFirst(RegExp(_scorePattern), '');
    _notesCtrl.text = t;
    _notesCtrl.selection =
        TextSelection.collapsed(offset: _notesCtrl.text.length);
  }

  Widget _buildHealingTypeSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text('子人格类型',
                style: TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: ['欲望类子人格', '恐惧类子人格'].map((t) {
                  final selected = _selectedHealingType == t;
                  return GestureDetector(
                    onTap: () => _onHealingTypeTap(t),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? _kPurple : const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF555555),
                          fontWeight:
                              selected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );

  void _onHealingTypeTap(String type) {
    setState(() {
      if (_selectedHealingType == type) {
        _selectedHealingType = null;
        _removeHealingTypeFromNotes();
      } else {
        _selectedHealingType = type;
        _applyHealingTypeToNotes();
      }
    });
  }

  void _applyHealingTypeToNotes() {
    var t = _notesCtrl.text;
    t = t.replaceFirst(RegExp(r'^(?:欲望类子人格|恐惧类子人格)\s?'), '');
    _notesCtrl.text = '$_selectedHealingType $t';
    _notesCtrl.selection =
        TextSelection.collapsed(offset: _notesCtrl.text.length);
  }

  void _removeHealingTypeFromNotes() {
    var t = _notesCtrl.text;
    t = t.replaceFirst(RegExp(r'^(?:欲望类子人格|恐惧类子人格)\s?'), '');
    _notesCtrl.text = t;
    _notesCtrl.selection =
        TextSelection.collapsed(offset: _notesCtrl.text.length);
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
              maxLines: 5,
              maxLength: 500,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.type == '觉察' ? AppLocalizations.of(context).awarenessNotesHint : widget.type == '疗愈' ? AppLocalizations.of(context).healingNotesHint : widget.type == '真我' ? AppLocalizations.of(context).trueSelfNotesHint : widget.type == '学与教' ? AppLocalizations.of(context).learningTeachingNotesHint : AppLocalizations.of(context).genericNotesHint,
                hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                border: InputBorder.none,
                counterStyle: const TextStyle(color: Color(0xFFBBBBBB)),
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
      setState(() => _endTime = DateTime(
          prev.year, prev.month, prev.day, p.hour, p.minute));
    }
  }

  void _save() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final entry = GenericEntry(
      id: _isEdit
          ? widget.entry!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      type: widget.type,
      startTime: _startTime,
      endTime: _endTime,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      statusScore: _selectedScore,
      healingType: _selectedHealingType,
    );
    if (_isEdit) {
      provider.updateGeneric(entry);
    } else {
      provider.addGeneric(entry);
    }
    Navigator.pop(context);
  }

  void _delete() {
    Provider.of<AppProvider>(context, listen: false)
        .removeEntry('generic', widget.entry!.id);
    Navigator.pop(context);
  }
}
