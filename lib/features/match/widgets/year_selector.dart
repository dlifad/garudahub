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

  final List<int>         years;    // angka tahun, sudah DESC; -1 = all-time
  final int               selected;
  final ValueChanged<int> onChanged;

  String _label(int y) => y == kAllTimeYear ? 'All Time' : '$y';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Pastikan list diakhiri kAllTimeYear
    final items = [
      ...years.where((y) => y != kAllTimeYear),
      kAllTimeYear,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            'Pilih Tahun',
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DropdownYear(
              items:    items,
              selected: selected,
              onChanged: onChanged,
              labelFn:  _label,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownYear extends StatelessWidget {
  const _DropdownYear({
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.labelFn,
  });

  final List<int>         items;
  final int               selected;
  final ValueChanged<int> onChanged;
  final String Function(int) labelFn;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color:        cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outline.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value:        selected,
          isExpanded:   true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: cs.onSurfaceVariant, size: 20),
          style: tt.bodyMedium?.copyWith(
            color:      cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize:   13,
          ),
          dropdownColor: cs.surfaceContainerHighest,
          borderRadius:  BorderRadius.circular(14),
          items: items.map((y) {
            final isSelected = y == selected;
            return DropdownMenuItem<int>(
              value: y,
              child: Row(children: [
                if (isSelected)
                  Container(
                    width: 6, height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color:        const Color(0xFFCC0001),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )
                else
                  const SizedBox(width: 14),
                Text(
                  labelFn(y),
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFCC0001)
                        : null,
                    fontSize: 13,
                  ),
                ),
              ]),
            );
          }).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}
