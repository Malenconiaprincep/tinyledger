import 'package:flutter/material.dart';

import '../../app/stitch_icons.dart';
import '../../domain/ledger_models.dart';
import '../../domain/money.dart';

/// 流水行展示（首页摘要与全屏流水列表共用）。
class LedgerTransactionTile extends StatelessWidget {
  const LedgerTransactionTile({
    super.key,
    required this.tx,
    this.dense = false,
  });

  final LedgerTransaction tx;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final prefix = tx.signedAmountCents >= 0 ? '+' : '';
    final title = switch (tx.kind) {
      LedgerTxKind.income =>
        '收入${tx.category != null && tx.category!.isNotEmpty ? ' · ${tx.category}' : ''}',
      LedgerTxKind.expense =>
        '支出${tx.category != null ? ' · ${tx.category}' : ''}',
      LedgerTxKind.goalContribution => '转入目标',
      LedgerTxKind.learningBonus => '小金库奖励',
    };
    final amountStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: tx.signedAmountCents >= 0 ? scheme.secondary : scheme.tertiary,
    );
    final glyph = stitchLedgerTxIcon(tx);
    if (dense) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(glyph, color: scheme.onSurfaceVariant, size: 22),
        title: Text(title),
        subtitle: (tx.note ?? '').isEmpty ? null : Text(tx.note!),
        trailing: Text(
          '$prefix${formatCentsToYuan(tx.signedAmountCents.abs())}',
          style: amountStyle,
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(glyph, color: scheme.onSurfaceVariant, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              if ((tx.note ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    tx.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$prefix${formatCentsToYuan(tx.signedAmountCents.abs())}',
          style: amountStyle,
        ),
      ],
    );
  }
}
