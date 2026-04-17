import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_models.dart';
import '../../domain/money.dart';
import '../../providers.dart';
import '../ledger/ledger_transaction_tile.dart';
import '../record/add_record_page.dart';

/// 首页/资产（Stitch **首页/资产 - 趣味探索版**信息架构：渐变余额卡、紫渐变记一笔、今日摘要贴纸）。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static (int inc, int exp) _todayIncomeExpenseCents(
    List<LedgerTransaction> txs,
  ) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    var inc = 0;
    var exp = 0;
    for (final t in txs) {
      if (t.createdAt.isBefore(start)) continue;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    return snap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
      data: (data) {
        final (tInc, tExp) = _todayIncomeExpenseCents(data.transactions);
        final bottomInset = MediaQuery.paddingOf(context).bottom + 24;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '虚拟小金库 · 练习用',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PlayfulBalanceCard(balanceCents: data.balanceCents),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _PlayfulRecordCta(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddRecordPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '今日摘要',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(appShellTabIndexProvider.notifier).state = 2;
                      },
                      child: const Text('查看全部'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StickerStatCard(
                          label: '收入',
                          value: '+${formatCentsToYuan(tInc)}',
                          icon: Icons.south_east_rounded,
                          iconBg: scheme.primaryContainer,
                          iconColor: TinyLedgerPlayfulColors.primaryDim,
                          amountColor: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: _StickerStatCard(
                            label: '支出',
                            value: '-${formatCentsToYuan(tExp)}',
                            icon: Icons.north_west_rounded,
                            iconBg: scheme.tertiaryContainer,
                            iconColor: scheme.tertiary,
                            amountColor: scheme.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '最近流水',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(appShellTabIndexProvider.notifier).state = 2;
                      },
                      child: const Text('账本'),
                    ),
                  ],
                ),
              ),
            ),
            if (data.transactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
                  child: Text(
                    '还没有记录，点上面紫色「记一笔」开始吧。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
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
                          child: LedgerTransactionTile(tx: t, dense: true),
                        ),
                      ),
                    );
                  }, childCount: data.transactions.length.clamp(0, 6)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlayfulBalanceCard extends StatelessWidget {
  const _PlayfulBalanceCard({required this.balanceCents});

  final int balanceCents;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
        gradient: LinearGradient(
          colors: [scheme.primary, TinyLedgerPlayfulColors.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.38),
            blurRadius: 32,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: scheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '小金库',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '¥',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: _majorYuan(balanceCents),
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: _minorYuan(balanceCents),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.42,
                child: Image.asset(
                  'assets/images/stitch_playful_coin.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [formatCentsToYuan] 已含货币符号，此处去掉，避免与左侧单独样式的 `¥` 重复。
  static String _numericYuanString(int cents) {
    return formatCentsToYuan(cents).replaceFirst(RegExp(r'^[¥￥]\s*'), '');
  }

  static String _majorYuan(int cents) {
    final s = _numericYuanString(cents);
    final dot = s.indexOf('.');
    return dot < 0 ? s : s.substring(0, dot);
  }

  static String _minorYuan(int cents) {
    final s = _numericYuanString(cents);
    final dot = s.indexOf('.');
    return dot < 0 ? '' : s.substring(dot);
  }
}

class _PlayfulRecordCta extends StatelessWidget {
  const _PlayfulRecordCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.secondary, TinyLedgerPlayfulColors.secondaryDim],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.secondary.withValues(alpha: 0.32),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 18, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '新记录',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: scheme.secondaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '记一笔',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: scheme.onSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: scheme.onSecondary,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerStatCard extends StatelessWidget {
  const _StickerStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.amountColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      elevation: 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
