import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';

const Color _kPurple = Color(0xFF7B6CF6);

class FeedingPage extends StatefulWidget {
  const FeedingPage({super.key});

  @override
  State<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage> {
  DateTime _time = DateTime.now();
  int _amount = 250;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
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
                  _sectionCard([_timeRow()]),
                  const SizedBox(height: 10),
                  _sectionCard([_amountRow()]),
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
        title: const Text('母乳瓶喂记录',
            style: TextStyle(
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

  Widget _sectionCard(List<Widget> children) => Container(
        color: Colors.white,
        child: Column(children: children),
      );

  Widget _timeRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text('开始时间',
                style: TextStyle(fontSize: 16, color: Colors.black)),
            const Spacer(),
            _pillBtn(_dateLabel(), isTime: false, onTap: _pickDate),
            const SizedBox(width: 8),
            _pillBtn(DateFormat('HH:mm').format(_time),
                isTime: true, onTap: _pickTime),
          ],
        ),
      );

  String _dateLabel() {
    final now = DateTime.now();
    if (_time.year == now.year &&
        _time.month == now.month &&
        _time.day == now.day) return '今天';
    return DateFormat('MM-dd').format(_time);
  }

  Widget _pillBtn(String text,
          {required bool isTime, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isTime ? _kPurple : const Color(0xFF555555),
              fontWeight: isTime ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      );

  Widget _amountRow() => InkWell(
        onTap: _pickAmount,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('奶量',
                  style: TextStyle(fontSize: 16, color: Colors.black)),
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
            const Text('备注',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              maxLength: 200,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: '选填，比如宝宝是否有吐奶、肠胀气等不适情况',
                hintStyle:
                    TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
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
        child: SizedBox(
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
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          ),
        ),
      );

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (p != null) {
      setState(() => _time = DateTime(
          p.year, p.month, p.day, _time.hour, _time.minute));
    }
  }

  Future<void> _pickTime() async {
    final p = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_time));
    if (p != null) {
      setState(() => _time = DateTime(
          _time.year, _time.month, _time.day, p.hour, p.minute));
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
    Provider.of<AppProvider>(context, listen: false).addFeeding(FeedingEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: _time,
      amountMl: _amount,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }
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
      title: const Text('选择奶量'),
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
              labelText: '自定义 (mL)',
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
