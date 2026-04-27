import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/emojis.dart';
import '../models/baby_entries.dart';
import '../providers/app_provider.dart';
import 'custom_page.dart';
import 'generic_record_page.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // 疗愈 entries
    final healingEntries = provider.genericEntries
        .where((e) => e.type == '疗愈')
        .toList();

    // 学与教 entries where notes starts with "引导"
    final teachEntries = provider.customEntries
        .where((e) => e.notes != null && e.notes!.startsWith('引导'))
        .toList();

    // Merge and sort by startTime descending
    final items = <_SummaryItem>[];
    for (final e in healingEntries) {
      items.add(_SummaryItem(
        time: e.startTime,
        icon: AppEmojis.healing,
        notes: e.notes ?? '',
        type: 'healing',
        entry: e,
      ));
    }
    for (final e in teachEntries) {
      items.add(_SummaryItem(
        time: e.startTime,
        icon: AppEmojis.custom,
        notes: e.notes ?? '',
        type: 'teach',
        entry: e,
      ));
    }
    items.sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '子人格图鉴',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFDDDDDD)),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                '暂无记录',
                style: TextStyle(color: Color(0xFF999999), fontSize: 15),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: items.length,
              itemBuilder: (ctx, i) => _buildCard(context, items[i]),
            ),
    );
  }

  Widget _buildCard(BuildContext context, _SummaryItem item) {
    return GestureDetector(
      onTap: () {
        if (item.type == 'healing') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenericRecordPage(
                type: '疗愈',
                entry: item.entry as GenericEntry,
              ),
            ),
          );
        } else if (item.type == 'teach') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomPage(
                entry: item.entry as CustomEntry,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(10, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.type == 'healing'
                    ? const Color(0xFFF0EEFF)
                    : const Color(0xFFFFF5E0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MM-dd HH:mm').format(item.time),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.notes,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  final DateTime time;
  final String icon;
  final String notes;
  final String type; // 'healing' or 'teach'
  final dynamic entry;

  const _SummaryItem({
    required this.time,
    required this.icon,
    required this.notes,
    required this.type,
    required this.entry,
  });
}
