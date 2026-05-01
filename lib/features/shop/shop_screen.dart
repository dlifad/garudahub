import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:garudahub/features/shop/merchandise/providers/merchandise_provider.dart';
import 'package:garudahub/features/shop/merchandise/screens/merchandise_screen.dart';
import 'package:garudahub/features/shop/ticket/providers/ticket_provider.dart';
import 'package:garudahub/features/shop/ticket/screens/ticket_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _query = '';
  final FocusNode _searchFocus = FocusNode();

  double? _minPrice;
  double? _maxPrice;
  String _sortOption = 'default';

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MerchandiseProvider>().fetch();
    context.read<TicketProvider>().fetch();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Widget _buildSearchField(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cs.outlineVariant, width: 0.5),
      ),
      child: TextField(
        focusNode: _searchFocus,
        autofocus: false,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Cari...',
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _showFilterSortSheet(BuildContext context) {
    _searchFocus.unfocus();
    final cs = Theme.of(context).colorScheme;

    _minPriceController.text =
        _minPrice != null ? _minPrice!.toInt().toString() : '';
    _maxPriceController.text =
        _maxPrice != null ? _maxPrice!.toInt().toString() : '';

    String tempSort = _sortOption;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Filter & Urutkan'),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Filter Harga'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga Min',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga Max',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const SectionTitle(title: 'Urutkan'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SortChip(
                        label: 'Default',
                        value: 'default',
                        selected: tempSort,
                        onSelected: (v) => setSheetState(() => tempSort = v),
                      ),
                      _SortChip(
                        label: 'Harga Termurah',
                        value: 'price_asc',
                        selected: tempSort,
                        onSelected: (v) => setSheetState(() => tempSort = v),
                      ),
                      _SortChip(
                        label: 'Harga Termahal',
                        value: 'price_desc',
                        selected: tempSort,
                        onSelected: (v) => setSheetState(() => tempSort = v),
                      ),
                      _SortChip(
                        label: 'A → Z',
                        value: 'name_asc',
                        selected: tempSort,
                        onSelected: (v) => setSheetState(() => tempSort = v),
                      ),
                      _SortChip(
                        label: 'Z → A',
                        value: 'name_desc',
                        selected: tempSort,
                        onSelected: (v) => setSheetState(() => tempSort = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: GarudaButton(
                          text: 'Reset',
                          color: cs.surfaceContainerHighest,
                          onPressed: () {
                            _minPriceController.clear();
                            _maxPriceController.clear();
                            setSheetState(() => tempSort = 'default');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GarudaButton(
                          text: 'Terapkan',
                          onPressed: () {
                            FocusScope.of(ctx).unfocus();
                            setState(() {
                              final minText = _minPriceController.text.trim();
                              final maxText = _maxPriceController.text.trim();
                              _minPrice = minText.isNotEmpty
                                  ? double.tryParse(minText)
                                  : null;
                              _maxPrice = maxText.isNotEmpty
                                  ? double.tryParse(maxText)
                                  : null;
                              _sortOption = tempSort;
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool get _isFilterActive =>
      _minPrice != null || _maxPrice != null || _sortOption != 'default';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              color: cs.surface,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text('Shop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
        
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Expanded(child: _buildSearchField(context)),
                          const SizedBox(width: 8),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton.outlined(
                                onPressed: () => _showFilterSortSheet(context),
                                icon: const Icon(Icons.tune_rounded),
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              if (_isFilterActive)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
        
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: cs.onPrimary,
                          unselectedLabelColor: cs.onSurfaceVariant,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Merchandise'),
                            Tab(text: 'Tiket'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<MerchandiseProvider>().fetch(),
                    context.read<TicketProvider>().fetch(),
                  ]);
                },
                child: TabBarView(
                  children: [
                    MerchandiseScreen(
                      query: _query,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                      sortOption: _sortOption,
                    ),
                    TicketScreen(
                      query: _query,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                      sortOption: _sortOption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final cs = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      showCheckmark: false,
      selectedColor: cs.primary,
      labelStyle: TextStyle(
        color: isSelected ? cs.onPrimary : cs.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}