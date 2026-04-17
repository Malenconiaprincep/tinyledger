import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_models.dart';
import '../../providers.dart';
import 'ledger_transaction_tile.dart';

String _daySectionLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(day.year, day.month, day.day);
  if (d == today) return '今天';
  if (d == yesterday) return '昨天';
  return '${day.year}年${day.month}月${day.day}日';
}

/// 账本 Tab：按日分组的流水（对齐「流水列表 - iOS 温馨版」）。
class LedgerListPage extends ConsumerWidget {
  const LedgerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('账本')),
      body: snap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (data) {
          if (data.transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有流水',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '在「资产」页点「记一笔」，这里就会按日期排好。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final grouped = <DateTime, List<LedgerTransaction>>{};
          for (final t in data.transactions) {
            final d = DateTime(
              t.createdAt.year,
              t.createdAt.month,
              t.createdAt.day,
            );
            grouped.putIfAbsent(d, () => []).add(t);
          }
          final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemCount: _itemCount(days, grouped),
            itemBuilder: (ctx, index) {
              return _buildItem(context, scheme, index, days, grouped);
            },
          );
        },
      ),
    );
  }

  static int _itemCount(
    List<DateTime> days,
    Map<DateTime, List<LedgerTransaction>> grouped,
  ) {
    var n = 0;
    for (final d in days) {
      n += 1 + grouped[d]!.length;
    }
    return n;
  }

  static Widget _buildItem(
    BuildContext context,
    ColorScheme scheme,
    int index,
    List<DateTime> days,
    Map<DateTime, List<LedgerTransaction>> grouped,
  ) {
    var cursor = 0;
    for (final d in days) {
      if (cursor == index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(
            _daySectionLabel(d),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }
      cursor++;
      final txs = grouped[d]!;
      for (final t in txs) {
        if (cursor == index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: LedgerTransactionTile(tx: t),
              ),
            ),
          );
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }
}
