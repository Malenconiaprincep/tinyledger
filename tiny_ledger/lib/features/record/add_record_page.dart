import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/stitch_icons.dart';
import '../../domain/ledger_models.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

class AddRecordPage extends ConsumerStatefulWidget {
  const AddRecordPage({super.key});

  @override
  ConsumerState<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends ConsumerState<AddRecordPage> {
  String _amountStr = '0';
  bool _income = false;
  late String _category;
  final DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _category = kExpenseCategories.first;
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        _amountStr = _amountStr.length <= 1 ? '0' : _amountStr.substring(0, _amountStr.length - 1);
      } else if (key == '.') {
        if (!_amountStr.contains('.')) _amountStr += '.';
      } else {
        final dotIdx = _amountStr.indexOf('.');
        if (dotIdx != -1 && _amountStr.length - dotIdx > 2) return;
        _amountStr = _amountStr == '0' ? key : _amountStr + key;
      }
    });
  }

  Future<void> _save() async {
    final cents = tryParseYuanToCents(_amountStr);
    if (cents == null || cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入大于 0 的金额')),
      );
      return;
    }
    final recordedAt = DateTime(_date.year, _date.month, _date.day, 12);
    try {
      final svc = ref.read(ledgerServiceProvider);
      if (_income) {
        await svc.addIncome(
          amountCents: cents,
          note: '',
          category: _category,
          recordedAt: recordedAt,
        );
      } else {
        await svc.addExpense(
          amountCents: cents,
          category: _category,
          note: '',
          recordedAt: recordedAt,
        );
      }
      bumpLedger(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_income ? '已记录收入' : '已记录支出')),
      );
    } on LedgerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cats = _income ? kIncomeCategories : kExpenseCategories;
    final displayAmount = _amountStr == '0' ? '0.00' : _amountStr;

    final snapshot = ref.watch(ledgerSnapshotProvider);
    final balanceLabel = snapshot.when(
      data: (s) => formatCentsToYuan(s.balanceCents),
      loading: () => '...',
      error: (_, __) => '--',
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CircleButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).pop(),
                      scheme: scheme,
                    ),
                  ),
                  Text(
                    '记一笔',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // ── 收入 / 支出 切换 ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    _ToggleTab(
                      label: '支出',
                      selected: !_income,
                      scheme: scheme,
                      onTap: () => setState(() {
                        _income = false;
                        if (!kExpenseCategories.contains(_category)) {
                          _category = kExpenseCategories.first;
                        }
                      }),
                    ),
                    _ToggleTab(
                      label: '收入',
                      selected: _income,
                      scheme: scheme,
                      onTap: () => setState(() {
                        _income = true;
                        if (!kIncomeCategories.contains(_category)) {
                          _category = kIncomeCategories.first;
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── 金额大字 ──────────────────────────────────────────
            Center(
              child: Text(
                '¥ $displayAmount',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── 余额徽章 ──────────────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, size: 14, color: scheme.onTertiaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      '余额 $balanceLabel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── 分类选择（横向圆形图标）────────────────────────────
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final cat = cats[i];
                  final sel = cat == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: sel ? scheme.primary : scheme.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            boxShadow: sel
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Icon(
                            stitchCategoryIcon(income: _income, category: cat),
                            size: 22,
                            color: sel ? scheme.onPrimary : scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: sel ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── 数字键盘 ──────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NumPad(onKey: _onKey),
              ),
            ),

            // ── 保存按钮 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 辅助组件 ────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.scheme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: scheme.onSurface),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onKey});

  final void Function(String) onKey;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: _rows.map((row) {
        return Expanded(
          child: Row(
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () => onKey(k),
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: k == '⌫'
                            ? Icon(
                                Icons.backspace_outlined,
                                size: 22,
                                color: scheme.onSurface,
                              )
                            : Text(
                                k,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurface,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
