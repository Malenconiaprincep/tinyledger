import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/money.dart';
import '../../providers.dart';

/// 小金库 / 梦想金库：趣味展示当前余额与「假如多存一点」的预览，不产生额外入账。
class GrowthPage extends ConsumerWidget {
  const GrowthPage({super.key});

  static const _disclaimer =
      '小算盘里的金额来自你在首页记的账与目标存钱，不是真实银行卡余额，也不连接投资市场。';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final snap = ref.watch(ledgerSnapshotProvider);

    return snap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
      data: (data) {
        final bottomInset = MediaQuery.paddingOf(context).bottom + 88;
        final balanceText = formatCentsToYuan(data.balanceCents);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '梦想金库',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '趣味探索版 · 小金库',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _DreamVaultHeroCard(
                      scheme: scheme,
                      balanceText: balanceText,
                    ),
                    const SizedBox(height: 20),
                    const _GrowthDepositPreviewBlock(),
                    const SizedBox(height: 20),
                    Material(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        TinyLedgerLayout.cardRadius,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: scheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                GrowthPage._disclaimer,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      height: 1.35,
                                      color: scheme.onSurface,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: bottomInset),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 滑条与预览金额仅本地状态，用普通 [StatefulWidget] 承接。
class _GrowthDepositPreviewBlock extends StatefulWidget {
  const _GrowthDepositPreviewBlock();

  @override
  State<_GrowthDepositPreviewBlock> createState() =>
      _GrowthDepositPreviewBlockState();
}

class _GrowthDepositPreviewBlockState extends State<_GrowthDepositPreviewBlock> {
  double _sliderYuan = 100;

  int _previewMonthCents() =>
      ((_sliderYuan / 100.0) * 5.0 * 100).round().clamp(0, 1 << 30);

  int _previewYearCents() =>
      ((_sliderYuan / 100.0) * 60.0 * 100).round().clamp(0, 1 << 30);

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MagicDepositCard(
          scheme: s,
          depositPreviewYuan: _sliderYuan.round(),
          sliderYuan: _sliderYuan,
          onSliderChanged: (v) => setState(() => _sliderYuan = v),
        ),
        const SizedBox(height: 20),
        _GrowthPreviewBento(
          scheme: s,
          monthCents: _previewMonthCents(),
          yearCents: _previewYearCents(),
        ),
      ],
    );
  }
}

class _DreamVaultHeroCard extends StatelessWidget {
  const _DreamVaultHeroCard({
    required this.scheme,
    required this.balanceText,
  });

  final ColorScheme scheme;
  final String balanceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.12),
            scheme.secondaryContainer.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    '成长中',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 44,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '我的梦想金库',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            Text(
              'My Vault',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              balanceText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  '想增加余额？去首页点「记一笔」吧',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MagicDepositCard extends StatelessWidget {
  const _MagicDepositCard({
    required this.scheme,
    required this.depositPreviewYuan,
    required this.sliderYuan,
    required this.onSliderChanged,
  });

  final ColorScheme scheme;
  final int depositPreviewYuan;
  final double sliderYuan;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '存入魔法币',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '拖动滑条看看「假如多存一点」会长什么样——只是画面上的小游戏，不会真的改余额。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '本次预览',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '¥$depositPreviewYuan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: scheme.primary,
                inactiveTrackColor: scheme.primary.withValues(alpha: 0.15),
                thumbColor: scheme.primary,
                overlayColor: scheme.primary.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: sliderYuan.clamp(0, 1000),
                min: 0,
                max: 1000,
                divisions: 20,
                label: '¥${sliderYuan.round()}',
                onChanged: onSliderChanged,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¥0',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
                Text(
                  '¥1000',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthPreviewBento extends StatelessWidget {
  const _GrowthPreviewBento({
    required this.scheme,
    required this.monthCents,
    required this.yearCents,
  });

  final ColorScheme scheme;
  final int monthCents;
  final int yearCents;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BentoTile(
            scheme: scheme,
            title: '1 个月 · 趣味预览',
            amountText: '+${formatCentsToYuan(monthCents)}',
            icon: Icons.calendar_month_rounded,
            tint: scheme.primaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BentoTile(
            scheme: scheme,
            title: '1 年 · 趣味预览',
            amountText: '+${formatCentsToYuan(yearCents)}',
            icon: Icons.auto_graph_rounded,
            tint: scheme.secondaryContainer,
          ),
        ),
      ],
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.scheme,
    required this.title,
    required this.amountText,
    required this.icon,
    required this.tint,
  });

  final ColorScheme scheme;
  final String title;
  final String amountText;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amountText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
