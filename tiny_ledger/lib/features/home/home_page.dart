import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_header.dart';
import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_models.dart';
import '../../domain/money.dart';
import '../../providers.dart';
import '../ledger/ledger_transaction_tile.dart';
import '../record/add_record_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return '上午好';
    if (h < 18) return '下午好';
    return '晚上好';
  }

  static (int inc, int exp) _weekIncomeExpenseCents(
    List<LedgerTransaction> txs,
  ) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    var inc = 0;
    var exp = 0;
    for (final t in txs) {
      if (t.createdAt.isBefore(cutoff)) continue;
      switch (t.kind) {
        case LedgerTxKind.income:
        case LedgerTxKind.learningBonus:
          inc += t.signedAmountCents;
        case LedgerTxKind.expense:
          exp += t.signedAmountCents.abs();
        case LedgerTxKind.goalContribution:
          break;
      }
    }
    return (inc, exp);
  }

  static SavingsGoal? _featuredGoal(List<SavingsGoal> goals) {
    for (final g in goals) {
      if (!g.isCompleted) return g;
    }
    return goals.isEmpty ? null : goals.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: snap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (data) {
          final (wInc, wExp) = _weekIncomeExpenseCents(data.transactions);
          final goal = _featuredGoal(data.goals);
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TinyLedgerAppHeader(),
                            Text(
                              '${_greeting()}，今天也来看看小金库吧',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '下面都是练习用的虚拟金额，不是真钱哦。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: scheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          TinyLedgerLayout.cardRadius,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '学习账户 · 虚拟余额',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatCentsToYuan(data.balanceCents),
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.02,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MiniStatCard(
                              title: '近7 天收入',
                              value: '+${formatCentsToYuan(wInc)}',
                              icon: Icons.trending_up,
                              tone: scheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStatCard(
                              title: '近 7 天支出',
                              value: '-${formatCentsToYuan(wExp)}',
                              icon: Icons.trending_down,
                              tone: scheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (goal != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Material(
                          color: scheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                            TinyLedgerLayout.cardRadius,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              TinyLedgerLayout.cardRadius,
                            ),
                            onTap: () {
                              ref
                                  .read(appShellTabIndexProvider.notifier)
                                  .state = 1;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '进行中的目标',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    goal.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: goal.progress.clamp(0, 1),
                                      backgroundColor:
                                          scheme.surfaceContainerHigh,
                                      color: scheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${formatCentsToYuan(goal.savedCents)} / ${formatCentsToYuan(goal.targetCents)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '最近流水',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(appShellTabIndexProvider.notifier)
                                  .state = 2;
                            },
                            child: const Text('去账本'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (data.transactions.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        child: Text(
                          '还没有记录，点右下角「记一笔」开始吧。',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((ctx, i) {
                          final t = data.transactions[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: scheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: LedgerTransactionTile(
                                  tx: t,
                                  dense: true,
                                ),
                              ),
                            ),
                          );
                        }, childCount: data.transactions.length.clamp(0, 6)),
                      ),
                    ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddRecordPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('记一笔'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: tone),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
