import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/features/shop/merchandise/providers/merchandise_provider.dart';
import 'package:garudahub/features/shop/merchandise/screens/merchandise_screen.dart';
import 'package:garudahub/features/shop/ticket/screens/ticket_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {

  String _query = '';
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<MerchandiseProvider>().fetch();
  }

  Widget _buildSearchField(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: cs.outlineVariant,
          width: 0.5,
        ),
      ),
      child: TextField(
        focusNode: _searchFocus,
        autofocus: false,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari merchandise atau tiket...',
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
          ),

          border: InputBorder.none,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Shop'),
                pinned: true,
                elevation: 0,
                backgroundColor: cs.surface,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _buildSearchField(context),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  Material(
                    color: cs.surface,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                          unselectedLabelColor:
                              cs.onSurfaceVariant,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Merchandise'),
                            Tab(text: 'Tiket'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },

          body: TabBarView(
            children: [
              MerchandiseScreen(query: _query),
              TicketScreen(), // nanti bisa pakai juga
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate(this.child);

  @override
  double get minExtent => 65;

  @override
  double get maxExtent => 65;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}