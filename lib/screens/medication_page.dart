import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';

const Color _kPurple = Color(0xFF7B6CF6);

const List<String> _kCommonMeds = [
  '钙', '铁', '锌', '维生素A', '维生素D', '美林（布洛芬）',
  '泰诺林（对乙酰氨基酚）', '溴己新', '氨溴索',
];

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  DateTime _time = DateTime.now();
  final List<String> _medicines = [];
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
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
                  _medicineSection(),
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
        title: const Text('疗愈记录',
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

  Widget _medicineSection() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('记录药品',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
                const Spacer(),
                GestureDetector(
                  onTap: _addMedicine,
                  child: const Text('+ 添加',
                      style:
                          TextStyle(fontSize: 15, color: _kPurple)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Added medicines
            if (_medicines.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _medicines.map((m) => _medChip(m)).toList(),
              ),
              const SizedBox(height: 12),
            ],
            // Input row
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: '请输入药品名称',
                        hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  Container(
                      width: 0.5,
                      height: 20,
                      color: const Color(0xFFCCCCCC)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _dosageCtrl,
                      decoration: const InputDecoration(
                        hintText: '选择剂量',
                        hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Common medicines
            Row(
              children: [
                const Text('常用疗愈',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF888888))),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Text('管理',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF888888))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _commonMedChip('+', isAdd: true),
                ..._kCommonMeds
                    .map((m) => _commonMedChip(m, isAdd: false)),
              ],
            ),
          ],
        ),
      );

  Widget _medChip(String name) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _kPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kPurple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                style: const TextStyle(fontSize: 13, color: _kPurple)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() => _medicines.remove(name)),
              child: const Icon(Icons.close, size: 14, color: _kPurple),
            ),
          ],
        ),
      );

  Widget _commonMedChip(String label, {required bool isAdd}) =>
      GestureDetector(
        onTap: () {
          if (!isAdd && !_medicines.contains(label)) {
            setState(() => _medicines.add(label));
          }
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF444444))),
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
                hintText: '选填',
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
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w500)),
          ),
        ),
      );

  void _addMedicine() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty && !_medicines.contains(name)) {
      final dosage = _dosageCtrl.text.trim();
      setState(() {
        _medicines.add(dosage.isEmpty ? name : '$name $dosage');
        _nameCtrl.clear();
        _dosageCtrl.clear();
      });
    }
  }

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
    // Collect pending input
    if (_nameCtrl.text.trim().isNotEmpty) _addMedicine();

    Provider.of<AppProvider>(context, listen: false).addMed(MedEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: _time,
      medicines: List.from(_medicines),
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }
}
