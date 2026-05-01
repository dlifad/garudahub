import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/core/constants/constants.dart';

import 'package:garudahub/features/shop/services/currency_formatter.dart';
import 'package:garudahub/features/shop/merchandise/providers/merchandise_provider.dart';
import 'package:garudahub/features/shop/merchandise/screens/merchandise_detail_screen.dart';

class MerchandiseScreen extends StatefulWidget {
  final String query;
  final double? minPrice;
  final double? maxPrice;
  final String sortOption; // 'default' | 'price_asc' | 'price_desc' | 'name_asc' | 'name_desc'

  const MerchandiseScreen({
    super.key,
    required this.query,
    this.minPrice,
    this.maxPrice,
    this.sortOption = 'default',
  });

  @override
  State<MerchandiseScreen> createState() => _MerchandiseScreenState();
}

class _MerchandiseScreenState extends State<MerchandiseScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showScrollToTop) {
        setState(() => _showScrollToTop = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MerchandiseProvider>();
    final base = AppConstants.baseUrl.replaceAll('/api', '');

    if (prov.error != null) {
      return Center(child: Text(prov.error!));
    }

    if (prov.items.isEmpty) {
      return const Center(child: Text('Belum ada merchandise'));
    }

    // Filter by query
    var filteredItems = prov.items.where((item) {
      return item.name.toLowerCase().contains(widget.query.toLowerCase());
    }).toList();

    // Filter by min price
    if (widget.minPrice != null) {
      filteredItems = filteredItems
          .where((item) => item.price >= widget.minPrice!)
          .toList();
    }

    // Filter by max price
    if (widget.maxPrice != null) {
      filteredItems = filteredItems
          .where((item) => item.price <= widget.maxPrice!)
          .toList();
    }

    // Sorting
    switch (widget.sortOption) {
      case 'price_asc':
        filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name_asc':
        filteredItems.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        filteredItems.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      default:
        break;
    }

    if (filteredItems.isEmpty) {
      return const Center(child: Text('Merchandise Tidak ditemukan'));
    }

    return Stack(
      children: [
        GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: filteredItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, i) {
            final item = filteredItems[i];
            return GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();

                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => MerchandiseDetailScreen(item: item),
                    transitionsBuilder: (_, animation, _, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );

                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'merch-image-${item.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: item.imageUrl.isNotEmpty
                              ? Image.network(
                                  '$base${item.imageUrl}',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Center(
                                      child: Icon(Icons.broken_image)),
                                )
                              : const Center(child: Icon(Icons.image)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatCurrency(item.price, 'IDR'),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (prov.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),

        if (_showScrollToTop)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              tooltip: 'Kembali ke atas',
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
      ],
    );
  }
}