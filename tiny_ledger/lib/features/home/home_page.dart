import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ledger_models.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ledgerSnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: snap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('当前余额', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                formatCentsToYuan(data.balanceCents),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openIncomeSheet(context, ref),
                      icon: const Icon(Icons.savings_outlined),
                      label: const Text('记一笔收入'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openExpenseSheet(context, ref),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('记一笔支出'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('最近流水', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.transactions.isEmpty)
                Text(
                  '还没有记录，先从「收入」或「支出」开始吧。',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...data.transactions.take(30).map((t) => _TxTile(tx: t)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openIncomeSheet(BuildContext context, WidgetRef ref) async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('记录收入', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: '金额（元）',
                  hintText: '例如 10 或 10.5',
                ),
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: '备注（可选）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('保存'),
              ),
            ],
          ),
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
          .addIncome(amountCents: cents, note: noteCtrl.text);
      bumpLedger(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已记录收入')));
      }
    } on LedgerException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _openExpenseSheet(BuildContext context, WidgetRef ref) async {
    String category = kExpenseCategories.last;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('记录支出', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: '金额（元）'),
                  ),
                  DropdownButtonFormField<String>(
                    value: category,
                    items:
                        kExpenseCategories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => category = v ?? category),
                    decoration: const InputDecoration(labelText: '分类'),
                  ),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: '备注（可选）'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
          },
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
          .addExpense(
            amountCents: cents,
            category: category,
            note: noteCtrl.text,
          );
      bumpLedger(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已记录支出')));
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

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});

  final LedgerTransaction tx;

  @override
  Widget build(BuildContext context) {
    final prefix = tx.signedAmountCents >= 0 ? '+' : '';
    final title = switch (tx.kind) {
      LedgerTxKind.income => '收入',
      LedgerTxKind.expense =>
        '支出${tx.category != null ? ' · ${tx.category}' : ''}',
      LedgerTxKind.goalContribution => '转入目标',
      LedgerTxKind.learningBonus => '学习奖励（模拟）',
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(tx.note ?? ''),
      trailing: Text('$prefix${formatCentsToYuan(tx.signedAmountCents.abs())}'),
    );
  }
}
