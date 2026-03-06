import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/health_provider.dart';

void main() {
  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HealthProvider(),
      child: MaterialApp(
        title: '健康记录',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HealthTrackerHome(),
      ),
    );
  }
}

class HealthTrackerHome extends StatefulWidget {
  const HealthTrackerHome({super.key});

  @override
  State<HealthTrackerHome> createState() => _HealthTrackerHomeState();
}

class _HealthTrackerHomeState extends State<HealthTrackerHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '概览'),
            Tab(icon: Icon(Icons.water_drop), text: '喝水'),
            Tab(icon: Icon(Icons.medication), text: '吃药'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const OverviewTab(),
          WaterTab(),
          MedicationTab(),
        ],
      ),
    );
  }
}

// Overview Tab
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final todayWater = provider.getTodayWaterTotal();
    final todayMeds = provider.getTodayMedications();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日统计',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blue, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            '$todayWater ml',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Text('今日喝水'),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.medication, color: Colors.green, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            '${todayMeds.length} 次',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Text('今日吃药'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Water Entries
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近喝水记录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (provider.waterEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('暂无记录', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...provider.waterEntries.reversed.take(5).map((entry) => ListTile(
                          leading: const Icon(Icons.water_drop, color: Colors.blue),
                          title: Text('${entry.amount} ml'),
                          subtitle: Text(DateFormat('HH:mm').format(entry.timestamp)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeWaterEntry(entry.id),
                          ),
                        )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Medication Entries
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近吃药记录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (provider.medicationEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('暂无记录', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...provider.medicationEntries.reversed.take(5).map((entry) => ListTile(
                          leading: const Icon(Icons.medication, color: Colors.green),
                          title: Text(entry.name),
                          subtitle: Text('${entry.dosage} • ${DateFormat('HH:mm').format(entry.timestamp)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeMedicationEntry(entry.id),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Water Tab
class WaterTab extends StatefulWidget {
  const WaterTab({super.key});

  @override
  State<WaterTab> createState() => _WaterTabState();
}

class _WaterTabState extends State<WaterTab> {
  final _amountController = TextEditingController(text: '250');
  final List<int> _presetAmounts = [100, 200, 250, 300, 500];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Add Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '快速记录喝水',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _presetAmounts.map((amount) {
                      return FilterChip(
                        label: Text('$amount ml'),
                        selected: _amountController.text == amount.toString(),
                        onSelected: (selected) {
                          setState(() {
                            _amountController.text = amount.toString();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '水量 (ml)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          final amount = int.tryParse(_amountController.text);
                          if (amount != null && amount > 0) {
                            provider.addWaterEntry(amount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('已记录 $amount ml 喝水')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入有效的水量')),
                            );
                          }
                        },
                        child: const Text('记录'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Today's Water Entries
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日喝水记录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (provider.waterEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('暂无记录', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...provider.waterEntries.where((entry) {
                      final today = DateTime.now();
                      return entry.timestamp.year == today.year &&
                             entry.timestamp.month == today.month &&
                             entry.timestamp.day == today.day;
                    }).toList().reversed.map((entry) => ListTile(
                          leading: const Icon(Icons.water_drop, color: Colors.blue),
                          title: Text('${entry.amount} ml'),
                          subtitle: Text(DateFormat('HH:mm').format(entry.timestamp)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeWaterEntry(entry.id),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Medication Tab
class MedicationTab extends StatefulWidget {
  const MedicationTab({super.key});

  @override
  State<MedicationTab> createState() => _MedicationTabState();
}

class _MedicationTabState extends State<MedicationTab> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Medication Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '记录吃药',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '药物名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: '剂量 (如: 1片, 10ml)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: '备注 (可选)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final dosage = _dosageController.text.trim();

                        if (name.isNotEmpty && dosage.isNotEmpty) {
                          provider.addMedicationEntry(
                            name,
                            dosage,
                            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
                          );

                          // Clear form
                          _nameController.clear();
                          _dosageController.clear();
                          _notesController.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已记录 $name 吃药')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请填写药物名称和剂量')),
                          );
                        }
                      },
                      child: const Text('记录'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Today's Medication Entries
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日吃药记录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (provider.medicationEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('暂无记录', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...provider.medicationEntries.where((entry) {
                      final today = DateTime.now();
                      return entry.timestamp.year == today.year &&
                             entry.timestamp.month == today.month &&
                             entry.timestamp.day == today.day;
                    }).toList().reversed.map((entry) => ListTile(
                          leading: const Icon(Icons.medication, color: Colors.green),
                          title: Text(entry.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('剂量: ${entry.dosage}'),
                              Text('时间: ${DateFormat('HH:mm').format(entry.timestamp)}'),
                              if (entry.notes != null && entry.notes!.isNotEmpty)
                                Text('备注: ${entry.notes!}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeMedicationEntry(entry.id),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}