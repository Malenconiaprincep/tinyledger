import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '还没有目标。点右上角「+」创建一个吧，比如「买一本书」或「存零花钱」。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final g = data.goals[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              g.name,
                              style: Theme.of(ctx).textTheme.titleMedium,
                            ),
                          ),
                          if (g.isCompleted) const Chip(label: Text('已完成')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: g.progress.clamp(0, 1)),
                      const SizedBox(height: 8),
                      Text(
                        '${formatCentsToYuan(g.savedCents)} / ${formatCentsToYuan(g.targetCents)}',
                        style: Theme.of(ctx).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写正确的目标名称和金额')),
      );
      return;
    }
    try {
      await ref
          .read(ledgerServiceProvider)
          .createGoal(name: nameCtrl.text, targetCents: targetCents);
      bumpLedger(ref);
      if (context.mounted) {
        final name = nameCtrl.text.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已创建目标「$name」')),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入大于 0 的金额')),
      );
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
