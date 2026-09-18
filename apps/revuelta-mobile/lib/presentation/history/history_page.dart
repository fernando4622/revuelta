import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';

/// Screen representing "Historial" (Mockup Screen 7).
/// Features filter chips [Todos | En uso | Devueltos] and chronological history cards.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedFilter = 0; // 0: Todos, 1: En uso, 2: Devueltos

  final List<Map<String, dynamic>> _historyItems = [
    {
      'code': '#RV-0247',
      'status': 'RETURNED',
      'statusLabel': 'Devuelto',
      'timestamp': 'Hoy, 11:24 a.m.',
      'type': 'Bento Lunch',
    },
    {
      'code': '#RV-0183',
      'status': 'IN_USE',
      'statusLabel': 'En uso',
      'timestamp': 'Hace 1 h',
      'type': 'Vaso 500 ml',
    },
    {
      'code': '#RV-0102',
      'status': 'RETURNED',
      'statusLabel': 'Devuelto',
      'timestamp': 'Ayer, 4:32 p.m.',
      'type': 'Bowl Almuerzo',
    },
    {
      'code': '#RV-0076',
      'status': 'RETURNED',
      'statusLabel': 'Devuelto',
      'timestamp': '12 abr, 10:15 a.m.',
      'type': 'Vaso 360 ml',
    },
    {
      'code': '#RV-0031',
      'status': 'IN_USE',
      'statusLabel': 'En uso',
      'timestamp': '11 abr, 2:20 p.m.',
      'type': 'Bowl Almuerzo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _historyItems.where((item) {
      if (_selectedFilter == 1) return item['status'] == 'IN_USE';
      if (_selectedFilter == 2) return item['status'] == 'RETURNED';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Segmented Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _FilterChipItem(
                    label: 'Todos',
                    isSelected: _selectedFilter == 0,
                    onTap: () => setState(() => _selectedFilter = 0),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipItem(
                    label: 'En uso',
                    isSelected: _selectedFilter == 1,
                    onTap: () => setState(() => _selectedFilter = 1),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipItem(
                    label: 'Devueltos',
                    isSelected: _selectedFilter == 2,
                    onTap: () => setState(() => _selectedFilter = 2),
                  ),
                ],
              ),
            ),

            // History items list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isInUse = item['status'] == 'IN_USE';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isInUse ? AppColors.mintGreen : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lunch_dining,
                              color: isInUse ? AppColors.forestGreen : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['code'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['statusLabel']} \u2022 ${item['timestamp']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isInUse ? AppColors.forestGreen : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textHint),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
