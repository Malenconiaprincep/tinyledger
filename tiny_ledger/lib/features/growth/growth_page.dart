import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class GrowthPage extends ConsumerStatefulWidget {
  const GrowthPage({super.key});

  @override
  ConsumerState<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends ConsumerState<GrowthPage> {
  static const _disclaimer =
      '这里是「学习用模拟」：不会带来真实收益，也不连接股票/基金等市场数据。'
      '目的是让你理解「钱可以慢慢变多」的一种简单方式。';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('增值小知识')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _disclaimer,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            Text(
              '当前规则：每满 7 天可领取一次「学习奖励」¥5.00（模拟）。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
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
              child: const Text('尝试领取一次学习奖励（模拟）'),
            ),
            const Spacer(),
            Text(
              '提示：应用内所有计算都只使用这里写死的规则，不会访问外部金融市场接口。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
