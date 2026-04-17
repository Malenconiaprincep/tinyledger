import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('存钱目标'),
        actions: [
          IconButton(
            tooltip: '新建目标',
            onPressed: () => _createGoal(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: snap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (data) {
          if (data.goals.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  '给心愿一个小进度条',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          size: 48,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '还没有目标',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点右上角「+」创建一个吧，比如「买一本书」或「存零花钱」。',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: data.goals.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '给心愿一个小进度条',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                );
              }
              final g = data.goals[i - 1];
              return Material(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(
                  TinyLedgerLayout.cardRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              g.name,
                              style: Theme.of(ctx).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (g.isCompleted)
                            Chip(
                              label: const Text('已完成'),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: scheme.secondaryContainer,
                              labelStyle: TextStyle(
                                color: scheme.onSecondaryContainer,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: g.progress.clamp(0, 1),
                          backgroundColor: scheme.surfaceContainerHigh,
                          color: scheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${formatCentsToYuan(g.savedCents)} / ${formatCentsToYuan(g.targetCents)}',
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed:
                              g.isCompleted
                                  ? null
                                  : () =>
                                      _contribute(context, ref, g.id, g.name),
                          child: const Text('从余额转入'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('新建目标'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: '目标名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: '目标金额（元）'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    if (!context.mounted) return;
    final targetCents = tryParseYuanToCents(targetCtrl.text);
    if (nameCtrl.text.trim().isEmpty ||
        targetCents == null ||
        targetCents <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写正确的目标名称和金额')));
      return;
    }
    try {
      await ref
          .read(ledgerServiceProvider)
          .createGoal(name: nameCtrl.text, targetCents: targetCents);
      bumpLedger(ref);
      if (context.mounted) {
        final name = nameCtrl.text.trim();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已创建目标「$name」')));
      }
    } on LedgerException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
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
