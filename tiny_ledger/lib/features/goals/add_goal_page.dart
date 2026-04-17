import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

/// 新建目标（对齐 Stitch **「新建目标 - 趣味探索版」**）。
/// 主参考：`projects/16236738106685052013/screens/1e2d4f8b6119424a996116b7b9a232b5`
class AddGoalPage extends ConsumerStatefulWidget {
  const AddGoalPage({super.key});

  @override
  ConsumerState<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends ConsumerState<AddGoalPage> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '500');

  /// 贴纸仅用于稿面趣味展示，不落库。
  int _stickerIndex = 0;

  static const _minYuan = 10.0;
  static const _maxYuan = 9999.0;

  static final _stickerIcons = <IconData>[
    Icons.directions_car_filled_rounded,
    Icons.rocket_launch_rounded,
    Icons.sports_esports_rounded,
    Icons.menu_book_rounded,
    Icons.cake_rounded,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _yuan {
    final v = double.tryParse(_amountCtrl.text.trim());
    if (v == null || v.isNaN) return _minYuan;
    return v.clamp(_minYuan, _maxYuan);
  }

  void _syncAmountField(double yuan) {
    final rounded = yuan.round();
    if (_amountCtrl.text != '$rounded') {
      _amountCtrl.text = '$rounded';
      _amountCtrl.selection = TextSelection.collapsed(
        offset: _amountCtrl.text.length,
      );
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final cents = tryParseYuanToCents(_amountCtrl.text);
    if (name.isEmpty || cents == null || cents <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写梦想名称和大于 0 的目标金额')));
      return;
    }
    try {
      await ref
          .read(ledgerServiceProvider)
          .createGoal(name: name, targetCents: cents);
      bumpLedger(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已创建梦想「$name」')));
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
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final r = TinyLedgerLayout.cardRadius;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surface,
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.25),
            radius: 1.15,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.22),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                scheme: scheme,
                radius: r,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionLabel(
                        text: '你的梦想是什么？',
                        scheme: scheme,
                        color: scheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      _DreamNameField(
                        controller: _nameCtrl,
                        scheme: scheme,
                        radius: r,
                      ),
                      const SizedBox(height: 28),
                      _SectionLabel(
                        text: '选择一个贴纸',
                        scheme: scheme,
                        color: scheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      _StickerPicker(
                        scheme: scheme,
                        radius: r,
                        selectedIndex: _stickerIndex,
                        icons: _stickerIcons,
                        onSelect: (i) => setState(() => _stickerIndex = i),
                      ),
                      const SizedBox(height: 28),
                      _AmountCard(
                        scheme: scheme,
                        radius: r,
                        amountController: _amountCtrl,
                        yuan: _yuan,
                        onSliderChanged: (v) {
                          setState(() => _syncAmountField(v));
                        },
                        onAmountChanged: () => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 12 + bottomPad),
                child: _CreateDreamButton(
                  scheme: scheme,
                  radius: r,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.scheme,
    required this.radius,
    required this.onClose,
  });

  final ColorScheme scheme;
  final double radius;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Material(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(radius),
            elevation: 0,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onClose,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.close_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '新目标',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.text,
    required this.scheme,
    required this.color,
  });

  final String text;
  final ColorScheme scheme;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _DreamNameField extends StatelessWidget {
  const _DreamNameField({
    required this.controller,
    required this.scheme,
    required this.radius,
  });

  final TextEditingController controller;
  final ColorScheme scheme;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radius),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: TextField(
          controller: controller,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '例如：新自行车…',
            hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }
}

class _StickerPicker extends StatelessWidget {
  const _StickerPicker({
    required this.scheme,
    required this.radius,
    required this.selectedIndex,
    required this.icons,
    required this.onSelect,
  });

  final ColorScheme scheme;
  final double radius;
  final int selectedIndex;
  final List<IconData> icons;
  final ValueChanged<int> onSelect;

  Color _iconColor(int i) {
    final mod = i % 3;
    return switch (mod) {
      0 => scheme.primary,
      1 => scheme.secondary,
      _ => scheme.tertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: icons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final sel = i == selectedIndex;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: () => onSelect(i),
              child: Ink(
                decoration: BoxDecoration(
                  color:
                      sel
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color:
                        sel
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.15),
                    width: sel ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Center(
                    child: Icon(icons[i], size: 36, color: _iconColor(i)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.scheme,
    required this.radius,
    required this.amountController,
    required this.yuan,
    required this.onSliderChanged,
    required this.onAmountChanged,
  });

  final ColorScheme scheme;
  final double radius;
  final TextEditingController amountController;
  final double yuan;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radius),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  Text(
                    '目标金额',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '¥',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: scheme.tertiary,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 140,
                            child: TextField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              textAlign: TextAlign.left,
                              style: Theme.of(
                                context,
                              ).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.primary,
                                height: 1,
                                fontSize: 40,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (_) => onAmountChanged(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 14,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 22,
                      ),
                      activeTrackColor: scheme.primary,
                      inactiveTrackColor: scheme.surfaceContainerHigh,
                      thumbColor: scheme.surfaceContainerLowest,
                      overlayColor: scheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Slider(
                      value: yuan.clamp(
                        _AddGoalPageState._minYuan,
                        _AddGoalPageState._maxYuan,
                      ),
                      min: _AddGoalPageState._minYuan,
                      max: _AddGoalPageState._maxYuan,
                      onChanged: onSliderChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateDreamButton extends StatelessWidget {
  const _CreateDreamButton({
    required this.scheme,
    required this.radius,
    required this.onPressed,
  });

  final ColorScheme scheme;
  final double radius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, TinyLedgerPlayfulColors.primaryDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: scheme.onPrimary, size: 26),
                const SizedBox(width: 8),
                Text(
                  '创建梦想',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
