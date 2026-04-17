import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../providers.dart';

class GrowthPage extends ConsumerWidget {
  const GrowthPage({super.key});

  static const _disclaimer =
      '这里是「学习用模拟」：不会带来真实收益，也不连接股票/基金等市场数据。'
      '目的是让你理解「钱可以慢慢变多」的一种简单方式。';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('增长模拟')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Material(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_graph_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '增长模拟',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: scheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _disclaimer,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '可以怎么理解「慢慢变多」？',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '想象你把零花钱放进一个「学习罐」：每隔一段时间，罐子里会多一点点（这里是应用里写好的规则，不是真实利息）。'
            '真正的理财更复杂，这里只做温和的介绍。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '当前规则',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '每满 7 天可领取一次「学习奖励」¥5.00（模拟）。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              final applied = await ref
                  .read(ledgerServiceProvider)
                  .tryApplyLearningBonus(
                    bonusAmountCents: 500,
                    intervalDays: 7,
                  );
              bumpLedger(ref);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(applied ? '已发放学习奖励（模拟）' : '还没到领取时间，过几天再来试试'),
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard_outlined),
            label: const Text('尝试领取一次学习奖励（模拟）'),
          ),
          const SizedBox(height: 28),
          Text(
            '提示：应用内所有计算都只使用这里写死的规则，不会访问外部金融市场接口。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.outline,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
