import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';
import '../constants/emojis.dart';

const Color _kPurple = Color(0xFF7B6CF6);

class SolidFoodPage extends StatefulWidget {
  const SolidFoodPage({super.key});

  @override
  State<SolidFoodPage> createState() => _SolidFoodPageState();
}

class _SolidFoodPageState extends State<SolidFoodPage> {
  DateTime _time = DateTime.now();
  bool _ate = true;
  final _amountCtrl = TextEditingController();
  String _unit = '数量'; // '数量' | 'mL'
  final List<String> _foodTypes = [];
  String? _texture;
  final _notesCtrl = TextEditingController();

  static const _foodTypeOptions = [
    '谷物', '肉类', '水产', '蔬菜', '水果', '其他'
  ];

  static const _textureOptions = [
    _TextureOption('液体', AppEmojis.spoon, Color(0xFFFFF8E7)),
    _TextureOption('泥糊状', AppEmojis.spoon, Color(0xFFFFEFD0)),
    _TextureOption('碎末状', AppEmojis.spoon, Color(0xFFEFE8D8)),
    _TextureOption('颗粒状', AppEmojis.spoon, Color(0xFFE8D8C0)),
    _TextureOption('小块状', AppEmojis.spoon, Color(0xFFDDC8A8)),
    _TextureOption('大块状', AppEmojis.spoon, Color(0xFFD0B890)),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
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
                  _sectionCard([_ateRow()]),
                  if (_ate) ...[
                    const SizedBox(height: 10),
                    _sectionCard([_amountRow()]),
                    const SizedBox(height: 10),
                    _foodTypeSection(),
                    const SizedBox(height: 10),
                    _textureSection(),
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
        title: const Text('辅食记录',
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
            const Text('记录时间',
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

  Widget _ateRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text('是否进食',
                style: TextStyle(fontSize: 16, color: Colors.black)),
            const Spacer(),
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _ate,
                activeColor: _kPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (v) => setState(() => _ate = v ?? true),
              ),
            ),
          ],
        ),
      );

  Widget _amountRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text('进食量',
                style: TextStyle(fontSize: 16, color: Colors.black)),
            const Spacer(),
            // Toggle buttons
            _unitToggle('数量'),
            const SizedBox(width: 8),
            _unitToggle('mL'),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                      color: Color(0xFFBBBBBB)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style:
                    const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      );

  Widget _unitToggle(String label) {
    final sel = _unit == label;
    return GestureDetector(
      onTap: () => setState(() => _unit = label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFF2F2F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel
                  ? const Color(0xFFDDDDDD)
                  : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: sel ? _kPurple : const Color(0xFF999999),
            fontWeight: sel ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _foodTypeSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('辅食类型',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
                const SizedBox(width: 8),
                const Text('可多选',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF999999))),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _foodTypeOptions
                  .map((t) => _foodTypeChip(t))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _foodTypeChip(String type) {
    final sel = _foodTypes.contains(type);
    return GestureDetector(
      onTap: () => setState(() {
        if (sel) {
          _foodTypes.remove(type);
        } else {
          _foodTypes.add(type);
        }
      }),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? _kPurple.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? _kPurple : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 14,
            color: sel ? _kPurple : const Color(0xFF444444),
          ),
        ),
      ),
    );
  }

  Widget _textureSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('辅食性状',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _textureOptions
                    .map((t) => _textureItem(t))
                    .toList(),
              ),
            ),
          ],
        ),
      );

  Widget _textureItem(_TextureOption opt) {
    final sel = _texture == opt.label;
    return GestureDetector(
      onTap: () =>
          setState(() => _texture = sel ? null : opt.label),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: sel ? _kPurple.withOpacity(0.08) : opt.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? _kPurple : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(opt.emoji,
                    style: const TextStyle(fontSize: 30)),
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
                hintText: '选填',
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
    final amtStr = _amountCtrl.text.trim();
    Provider.of<AppProvider>(context, listen: false).addSolidFood(
        SolidFoodEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: _time,
          ate: _ate,
          amount:
              amtStr.isEmpty ? null : double.tryParse(amtStr),
          unit: _unit,
          foodTypes: List.from(_foodTypes),
          texture: _texture,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        ));
    Navigator.pop(context);
  }
}

class _TextureOption {
  final String label;
  final String emoji;
  final Color color;
  const _TextureOption(this.label, this.emoji, this.color);
}
