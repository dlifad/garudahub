import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/core/constants/constants.dart';

import 'package:garudahub/features/shop/services/currency_formatter.dart';
import 'package:garudahub/features/shop/merchandise/providers/merchandise_provider.dart';
import 'package:garudahub/features/shop/merchandise/screens/merchandise_detail_screen.dart';


class MerchandiseScreen extends StatefulWidget {
  final String query;
  const MerchandiseScreen({super.key, required this.query,});

  @override
  State<MerchandiseScreen> createState() => _MerchandiseScreenState();
}

class _MerchandiseScreenState extends State<MerchandiseScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MerchandiseProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MerchandiseProvider>();
    final base = AppConstants.baseUrl.replaceAll('/api', '');
    
    if (prov.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.error != null) {
      return Center(child: Text(prov.error!));
    }

    if (prov.items.isEmpty) {
      return const Center(child: Text('Belum ada merchandise'));
    }

    final filteredItems = prov.items.where((item) {
      return item.name
          .toLowerCase()
          .contains(widget.query.toLowerCase());
    }).toList();

    if (filteredItems.isEmpty) {
      return const Center(child: Text('Tidak ditemukan'));
    }

    return GridView.builder(
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
              MaterialPageRoute(
                builder: (_) => MerchandiseDetailScreen(item: item),
              ),
            );

            // 🔥 TAMBAH INI (paksa hilang focus setelah balik)
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            '$base${item.imageUrl}',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Center(child: Icon(Icons.broken_image)),
                          )
                        : const Center(child: Icon(Icons.image)),
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
    );
  }
}