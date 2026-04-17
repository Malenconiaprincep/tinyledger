import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';
import 'add_goal_page.dart';
import 'dream_goal_card.dart';
import 'goal_list_models.dart';

/// 存钱目标：对齐 Stitch「存钱目标 - iOS 温馨版」布局；含设计稿配图与演示数据，接服务器后可关掉演示段。
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  /// 接后端后改为 false，仅展示接口返回的目标。
  static const bool showStitchSamples = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    return snap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
      data: (data) {
        final realItems = <GoalListItem>[
          for (var i = 0; i < data.goals.length; i++)
            GoalListItem.fromSavingsGoal(
              data.goals[i],
              i.isEven
                  ? GoalProgressTone.secondary
                  : GoalProgressTone.tertiary,
            ),
        ];
        final bottomInset = MediaQuery.paddingOf(context).bottom + 88;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的目标',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '离梦想越来越近啦！继续加油哦～ \u{1F31F}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _NewGoalGradientCta(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AddGoalPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
              if (realItems.isEmpty && !showStitchSamples)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Text(
                      '还没有自己的目标，点上面「设立新目标」开始吧。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              for (final item in realItems)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: DreamGoalCard(
                      item: item,
                      onContribute:
                          item.isCompleted
                              ? null
                              : () => _contribute(
                                context,
                                ref,
                                item.id,
                                item.title,
                              ),
                    ),
                  ),
                ),
              if (showStitchSamples && realItems.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      '心愿示例（仅演示，不接余额）',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (showStitchSamples)
                for (final item in kStitchSampleGoals)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: DreamGoalCard(item: item),
                    ),
                  ),
            SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
          ],
        );
      },
    );
  }

  Future<void> _contribute(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    String goalName,
  ) async {
    final amountCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('转入「$goalName」'),
          content: TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '金额（元）'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    if (!context.mounted) return;
    final cents = tryParseYuanToCents(amountCtrl.text);
    if (cents == null || cents <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入大于 0 的金额')));
      return;
    }
    try {
      await ref
          .read(ledgerServiceProvider)
          .contributeToGoal(goalId: goalId, amountCents: cents);
      bumpLedger(ref);
      final snap = await ref.read(ledgerSnapshotProvider.future);
      final g = snap.goals.firstWhere((x) => x.id == goalId);
      if (context.mounted && g.isCompleted) {
        await showDialog<void>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('太棒了！'),
                content: const Text('你已经完成这个小目标啦（这是虚拟记账练习，不是真钱奖励）。'),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('好的'),
                  ),
                ],
              ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已转入目标')));
      }
    } on LedgerException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _NewGoalGradientCta extends StatelessWidget {
  const _NewGoalGradientCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shadowColor: scheme.primary.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: scheme.onPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '设立新目标',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '你想攒钱买什么呢？',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onPrimary.withValues(alpha: 0.55),
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
