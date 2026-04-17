import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/ledger_service.dart';
import '../../domain/money.dart';
import '../../providers.dart';

/// 新建目标（对齐 Stitch **「新建目标 - 趣味探索版 (优化版)」**）。
///
/// 信息架构：顶栏返回 + 居中标题、渐变头图、白卡片内（名称 / 图标 / 金额滑块）、底部胶囊主按钮。
/// 若 Stitch 中该帧 `name` 或资源 id 有更新，请同步修改此处注释。
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

  static final _stickerChoices = <({IconData icon, String label})>[
    (icon: Icons.directions_car_filled_rounded, label: '出行'),
    (icon: Icons.rocket_launch_rounded, label: '探索'),
    (icon: Icons.sports_esports_rounded, label: '游戏'),
    (icon: Icons.menu_book_rounded, label: '阅读'),
    (icon: Icons.cake_rounded, label: '庆祝'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写梦想名称和大于 0 的目标金额')),
      );
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
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.28),
                    scheme.surface,
                    scheme.secondaryContainer.withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.38, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OptimizedAppBar(
                  scheme: scheme,
                  radius: r,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroHeadlineCard(scheme: scheme, radius: r),
                        const SizedBox(height: 18),
                        _DreamFormShell(
                          scheme: scheme,
                          radius: r,
                          nameController: _nameCtrl,
                          stickerIndex: _stickerIndex,
                          stickerChoices: _stickerChoices,
                          onStickerSelected: (i) =>
                              setState(() => _stickerIndex = i),
                          amountController: _amountCtrl,
                          yuan: _yuan,
                          onSliderChanged: (v) {
                            setState(() => _syncAmountField(v));
                          },
                          onAmountChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottomPad),
                  child: _OptimizedPrimaryCta(
                    scheme: scheme,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏：左侧圆形返回 + 居中标题副标题（与「记一笔」层级一致）。
class _OptimizedAppBar extends StatelessWidget {
  const _OptimizedAppBar({
    required this.scheme,
    required this.radius,
    required this.onBack,
  });

  final ColorScheme scheme;
  final double radius;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: scheme.surfaceContainerLowest.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              child: InkWell(
                onTap: onBack,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: scheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '新建目标',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '趣味探索版 · 优化布局',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 头图：渐变主色块 + 文案 + 装饰图标（稿面「新建目标」氛围区）。
class _HeroHeadlineCard extends StatelessWidget {
  const _HeroHeadlineCard({required this.scheme, required this.radius});

  final ColorScheme scheme;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius + 4),
        gradient: LinearGradient(
          colors: [scheme.primary, TinyLedgerPlayfulColors.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -24,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 18,
                        color: scheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '立一个小目标',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '给心愿取个名字，\n选个喜欢的图标，再定下要攒多少吧～',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 白卡片：表单主体（与探索版大圆角、轻描边一致）。
class _DreamFormShell extends StatelessWidget {
  const _DreamFormShell({
    required this.scheme,
    required this.radius,
    required this.nameController,
    required this.stickerIndex,
    required this.stickerChoices,
    required this.onStickerSelected,
    required this.amountController,
    required this.yuan,
    required this.onSliderChanged,
    required this.onAmountChanged,
  });

  final ColorScheme scheme;
  final double radius;
  final TextEditingController nameController;
  final int stickerIndex;
  final List<({IconData icon, String label})> stickerChoices;
  final ValueChanged<int> onStickerSelected;
  final TextEditingController amountController;
  final double yuan;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radius + 2),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius + 2),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: scheme.secondary, size: 22),
                const SizedBox(width: 8),
                Text(
                  '梦想信息',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '梦想名称',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _DreamNameField(
              controller: nameController,
              scheme: scheme,
              radius: radius,
            ),
            const SizedBox(height: 22),
            Text(
              '选一个代表图标',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _StickerPickerLabeled(
              scheme: scheme,
              radius: radius,
              selectedIndex: stickerIndex,
              choices: stickerChoices,
              onSelect: onStickerSelected,
            ),
            const SizedBox(height: 22),
            Text(
              '目标金额',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '拖动滑块可快速调整',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.outline,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            _AmountBlock(
              scheme: scheme,
              radius: radius,
              amountController: amountController,
              yuan: yuan,
              onSliderChanged: onSliderChanged,
              onAmountChanged: onAmountChanged,
            ),
          ],
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
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(radius),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: '例如：新自行车、暑假旅行…',
          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}

/// 横向图标 + 小标签（对齐记一笔分类行的探索版气质）。
class _StickerPickerLabeled extends StatelessWidget {
  const _StickerPickerLabeled({
    required this.scheme,
    required this.radius,
    required this.selectedIndex,
    required this.choices,
    required this.onSelect,
  });

  final ColorScheme scheme;
  final double radius;
  final int selectedIndex;
  final List<({IconData icon, String label})> choices;
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
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: choices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final sel = i == selectedIndex;
          final c = choices[i];
          return InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: () => onSelect(i),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56,
                    height: 56,
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
                                : scheme.outlineVariant.withValues(
                                  alpha: 0.2,
                                ),
                        width: sel ? 2 : 1.5,
                      ),
                      boxShadow: [
                        if (!sel)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        c.icon,
                        size: 28,
                        color: sel ? scheme.primary : _iconColor(i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: sel ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
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
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '¥',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.tertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 148,
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.primary,
                      height: 1,
                      fontSize: 44,
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
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '¥${_AddGoalPageState._minYuan.round()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '¥${_AddGoalPageState._maxYuan.round()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 12,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
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
    );
  }
}

/// 底部主按钮：全宽胶囊 + 渐变（优化版强调主 CTA）。
class _OptimizedPrimaryCta extends StatelessWidget {
  const _OptimizedPrimaryCta({
    required this.scheme,
    required this.onPressed,
  });

  final ColorScheme scheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(TinyLedgerLayout.pillButtonRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, TinyLedgerPlayfulColors.primaryDim],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, color: scheme.onPrimary, size: 22),
                const SizedBox(width: 10),
                Text(
                  '创建我的小目标',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
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
