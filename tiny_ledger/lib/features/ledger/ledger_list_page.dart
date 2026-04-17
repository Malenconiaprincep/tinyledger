import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../app/stitch_icons.dart';
import '../../domain/ledger_models.dart';
import '../../domain/money.dart';
import '../../providers.dart';

String _daySectionLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(day.year, day.month, day.day);
  final monthDay = '${day.month}月${day.day}日';
  if (d == today) return '今天 · $monthDay';
  if (d == yesterday) return '昨天 · $monthDay';
  return '${day.year}年$monthDay';
}

String _formatTime(DateTime time) {
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _txTitle(LedgerTransaction tx) => switch (tx.kind) {
  LedgerTxKind.income => tx.category?.isNotEmpty == true ? tx.category! : '收入',
  LedgerTxKind.expense => tx.category?.isNotEmpty == true ? tx.category! : '支出',
  LedgerTxKind.goalContribution => '存钱目标',
  LedgerTxKind.learningBonus => '学习奖励',
};

String _txMeta(LedgerTransaction tx) {
  final note = (tx.note ?? '').trim();
  if (note.isNotEmpty) return '${_formatTime(tx.createdAt)} · $note';
  return switch (tx.kind) {
    LedgerTxKind.income => '${_formatTime(tx.createdAt)} · 零花钱入账',
    LedgerTxKind.expense => '${_formatTime(tx.createdAt)} · 日常消费',
    LedgerTxKind.goalContribution => '${_formatTime(tx.createdAt)} · 转入目标',
    LedgerTxKind.learningBonus => '${_formatTime(tx.createdAt)} · 学习任务完成',
  };
}

/// 账本 Tab：按日分组的流水（对齐「账本流水 - 趣味探索版」）。
class LedgerListPage extends ConsumerWidget {
  const LedgerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    return snap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
      data: (data) {
        if (data.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
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
                    '我的账本',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '还没有发现记录，去首页点「记一笔」吧。',
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
        for (final txs in grouped.values) {
          txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
        final bottomInset = MediaQuery.paddingOf(context).bottom + 88;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的账本',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Here are all your discoveries!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, bottomInset),
              sliver: SliverList.builder(
                itemCount: _itemCount(days, grouped),
                itemBuilder: (ctx, index) {
                  return _buildItem(context, scheme, index, days, grouped);
                },
              ),
            ),
          ],
        );
      },
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
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  _daySectionLabel(d),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      cursor++;
      final txs = grouped[d]!;
      for (final t in txs) {
        if (cursor == index) {
          final amountPrefix = t.signedAmountCents >= 0 ? '+' : '-';
          final amountColor = t.signedAmountCents >= 0
              ? scheme.secondary
              : scheme.tertiary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        stitchLedgerTxIcon(t),
                        size: 22,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _txTitle(t),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _txMeta(t),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$amountPrefix${formatCentsToYuan(t.signedAmountCents.abs())}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Star Coins',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
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
