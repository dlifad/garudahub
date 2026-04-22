import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/core/constants/constants.dart';

import 'package:garudahub/features/shop/merchandise/models/merchandise_model.dart';
import 'package:garudahub/features/shop/providers/currency_provider.dart';
import 'package:garudahub/features/shop/services/currency_formatter.dart';

class MerchandiseDetailScreen extends StatefulWidget {
  final MerchandiseModel item;

  const MerchandiseDetailScreen({super.key, required this.item});

  @override
  State<MerchandiseDetailScreen> createState() => _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().setCurrency('IDR');
    });
  }
  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final converted = currency.convert(widget.item.price.toDouble());
    final cs = Theme.of(context).colorScheme;
    final base = AppConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.item.imageUrl.isNotEmpty
                    ? Image.network(
                        '$base${widget.item.imageUrl}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : const Center(child: Icon(Icons.image, size: 40)),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              formatCurrency(converted, currency.selected),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              children: ['IDR', 'USD', 'EUR', 'MYR'].map((c) {
                final isSelected = currency.selected == c;

                return ChoiceChip(
                  label: Text(c),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: cs.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : cs.onSurfaceVariant,
                  ),
                  onSelected: (_) {
                    context.read<CurrencyProvider>().setCurrency(c);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            if (widget.item.sizes.trim().isNotEmpty) ...[
              Text(
                'Ukuran: ${widget.item.sizes}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 12),

            Text(
              widget.item.description,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(widget.item.shopeeUrl);

                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Beli Sekarang'),
            ),
          )
        )
    );
  }
}