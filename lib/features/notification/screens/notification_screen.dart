import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import '../models/notification_item.dart';
import '../services/notification_inbox_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;
  List<NotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await NotificationInboxService.instance.getAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _markAllRead() async {
    await NotificationInboxService.instance.markAllRead();
    await _load();
  }

  Future<void> _clearAll() async {
    await NotificationInboxService.instance.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all),
            ),
          if (_items.isNotEmpty)
            IconButton(
              tooltip: 'Hapus semua',
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off, size: 48, color: cs.outline),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.md,
                AppSpacing.base,
                AppSpacing.lg,
              ),
              itemCount: _items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md - 2),
              itemBuilder: (_, i) => _NotificationCard(
                item: _items[i],
                onTap: () async {
                  if (!_items[i].isRead) {
                    await NotificationInboxService.instance.markRead(
                      _items[i].id,
                    );
                    await _load();
                  }
                },
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: item.isRead
              ? cs.surfaceContainerHighest
              : cs.primaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? cs.outlineVariant.withOpacity(0.4)
                : cs.primary.withOpacity(0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _typeIcon(item.type, cs),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Text(item.body, style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatTime(item.createdAt),
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeIcon(String type, ColorScheme cs) {
    IconData icon;
    switch (type) {
      case 'match':
        icon = Icons.calendar_month;
        break;
      case 'result':
        icon = Icons.sports_soccer;
        break;
      case 'quiz':
        icon = Icons.emoji_events;
        break;
      default:
        icon = Icons.notifications;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: cs.onPrimaryContainer, size: 22),
    );
  }

  String _formatTime(DateTime dt) {
    final two = (int v) => v.toString().padLeft(2, '0');
    final d = two(dt.day);
    final m = two(dt.month);
    final y = dt.year;
    final h = two(dt.hour);
    final min = two(dt.minute);
    return '$d/$m/$y $h:$min';
  }
}
