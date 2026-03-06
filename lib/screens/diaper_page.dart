import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';

const Color _kPurple = Color(0xFF7B6CF6);

class DiaperPage extends StatefulWidget {
  const DiaperPage({super.key});

  @override
  State<DiaperPage> createState() => _DiaperPageState();
}

class _DiaperPageState extends State<DiaperPage> {
  DateTime _time = DateTime.now();
  String _diaperType = 'wet'; // 'wet' | 'poop' | 'both'
  String? _urineColor;
  final List<String> _symptoms = [];
  final _notesCtrl = TextEditingController();

  static const _urineColors = [
    _ColorOption('白色', Color(0xFFF0F0F0)),
    _ColorOption('淡黄色', Color(0xFFFFF5C0)),
    _ColorOption('琥珀色', Color(0xFFD4A843)),
    _ColorOption('橙黄色', Color(0xFFE8912B)),
    _ColorOption('棕褐色', Color(0xFF8B5E3C)),
    _ColorOption('粉红色', Color(0xFFFFB6C1)),
  ];

  static const _symptomOptions = [
    _SymptomOption('尿布有结晶沉淀', '🧊'),
    _SymptomOption('尿液浑浊', '🫙'),
    _SymptomOption('尿中带血', '🩸'),
  ];

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
                  _diaperTypeSection(),
                  if (_diaperType != 'poop') ...[
                    const SizedBox(height: 10),
                    _urineColorSection(),
                    const SizedBox(height: 10),
                    _symptomsSection(),
                  ],
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
        title: const Text('换尿布记录',
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text,
              style: TextStyle(
                fontSize: 15,
                color: isTime ? _kPurple : const Color(0xFF555555),
                fontWeight:
                    isTime ? FontWeight.w500 : FontWeight.normal,
              )),
        ),
      );

  Widget _diaperTypeSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('尿布状态',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            Row(
              children: [
                _diaperOption('wet', '💧', '小便'),
                const SizedBox(width: 20),
                _diaperOption('poop', '💩', '大便'),
                const SizedBox(width: 20),
                _diaperOption('both', '💩💧', '大便+小便'),
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
            width: 64,
            height: 64,
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
                Text(emoji,
                    style: const TextStyle(fontSize: 28)),
                if (selected)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF555555))),
        ],
      ),
    );
  }

  Widget _urineColorSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('小便颜色',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _urineColors
                    .map((c) => _colorCircle(c))
                    .toList(),
              ),
            ),
          ],
        ),
      );

  Widget _colorCircle(_ColorOption opt) {
    final sel = _urineColor == opt.label;
    return GestureDetector(
      onTap: () => setState(
          () => _urineColor = sel ? null : opt.label),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: opt.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? _kPurple : const Color(0xFFDDDDDD),
                  width: sel ? 2.5 : 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(opt.label,
                style: TextStyle(
                    fontSize: 12,
                    color: sel
                        ? _kPurple
                        : const Color(0xFF666666))),
          ],
        ),
      ),
    );
  }

  Widget _symptomsSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('小便伴随性状',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
                SizedBox(width: 8),
                Text('（多选）',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF999999))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: _symptomOptions
                  .map((s) => _symptomItem(s))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _symptomItem(_SymptomOption opt) {
    final sel = _symptoms.contains(opt.label);
    return GestureDetector(
      onTap: () => setState(() {
        if (sel) {
          _symptoms.remove(opt.label);
        } else {
          _symptoms.add(opt.label);
        }
      }),
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: sel
                    ? _kPurple.withOpacity(0.08)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      sel ? _kPurple : const Color(0xFFEEEEEE),
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(opt.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                opt.label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: '选填，比如宝宝尿尿时是否有发烧、哭闹等',
                hintStyle:
                    TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                border: InputBorder.none,
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
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w500)),
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

  void _save() {
    Provider.of<AppProvider>(context, listen: false).addDiaper(DiaperEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: _time,
      diaperType: _diaperType,
      urineColor: _urineColor,
      symptoms: List.from(_symptoms),
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }
}

class _ColorOption {
  final String label;
  final Color color;
  const _ColorOption(this.label, this.color);
}

class _SymptomOption {
  final String label;
  final String emoji;
  const _SymptomOption(this.label, this.emoji);
}
