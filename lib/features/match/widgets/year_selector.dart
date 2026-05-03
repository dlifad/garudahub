import 'package:flutter/material.dart';

/// Nilai sentinel untuk "All Time"
const int kAllTimeYear = -1;

class YearSelector extends StatelessWidget {
  const YearSelector({
    super.key,
    required this.years,
    required this.selected,
    required this.onChanged,
  });

  final List<int> years;    // angka tahun, sudah DESC; -1 = all-time
  final int selected;
  final ValueChanged<int> onChanged;

  String _label(int y) => y == kAllTimeYear ? 'Semua' : '$y';

  @override
  Widget build(BuildContext context) {
    // Pastikan "Semua" (kAllTimeYear) selalu di akhir
    final items = [
      ...years.where((y) => y != kAllTimeYear),
      kAllTimeYear,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final year = items[index];
          final isSelected = year == selected;
          return _YearChip(
            label: _label(year),
            isSelected: isSelected,
            onTap: () => onChanged(year),
          );
        },
      ),
    );
  }
}

class _YearChip extends StatelessWidget {
  const _YearChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const red = Color(0xFFCC0001);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected
              ? red.withOpacity(0.10)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? red.withOpacity(0.30)
                : cs.outline.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...
              [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? red : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
