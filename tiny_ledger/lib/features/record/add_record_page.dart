import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_models.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

/// 整页记一笔（对齐「记一笔 - iOS 温馨版」：分段、金额、分类、日期、备注）。
class AddRecordPage extends ConsumerStatefulWidget {
  const AddRecordPage({super.key});

  @override
  ConsumerState<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends ConsumerState<AddRecordPage> {
  static const _disclaimer = '这是练习用的虚拟金额，不会动用真实资金，也不是理财产品或投资建议。';

  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _income = true;
  late String _category;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _category = kIncomeCategories.first;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime(_date.year, _date.month, _date.day),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final cents = tryParseYuanToCents(_amountCtrl.text);
    if (cents == null || cents <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入大于 0 的金额')));
      return;
    }
    final recordedAt = DateTime(_date.year, _date.month, _date.day, 12);
    try {
      final svc = ref.read(ledgerServiceProvider);
      if (_income) {
        await svc.addIncome(
          amountCents: cents,
          note: _noteCtrl.text,
          category: _category,
          recordedAt: recordedAt,
        );
      } else {
        await svc.addExpense(
          amountCents: cents,
          category: _category,
          note: _noteCtrl.text,
          recordedAt: recordedAt,
        );
      }
      bumpLedger(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_income ? '已记录收入' : '已记录支出')));
    } on LedgerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cats = _income ? kIncomeCategories : kExpenseCategories;
    final localeTag = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(localeTag).format(_date);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('记一笔'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('收入'),
                icon: Icon(Icons.south_west, size: 18),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('支出'),
                icon: Icon(Icons.north_east, size: 18),
              ),
            ],
            selected: {_income},
            onSelectionChanged: (s) {
              final next = s.first;
              setState(() {
                _income = next;
                final list = next ? kIncomeCategories : kExpenseCategories;
                if (!list.contains(_category)) {
                  _category = list.first;
                }
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            '金额',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '¥ ',
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '分类',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                cats.map((c) {
                  final sel = c == _category;
                  return ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    onSelected: (_) => setState(() => _category = c),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '日期',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: scheme.outline),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: '备注（可选）',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _disclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
    );
  }
}
