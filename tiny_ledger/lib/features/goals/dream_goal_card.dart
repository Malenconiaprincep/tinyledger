import 'package:flutter/material.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../domain/money.dart';
import 'goal_list_models.dart';

/// 存钱目标卡片（对齐 Stitch稿：左侧方图、标题+百分比药丸、说明、粗进度条）。
class DreamGoalCard extends StatelessWidget {
  const DreamGoalCard({super.key, required this.item, this.onContribute});

  final GoalListItem item;
  final VoidCallback? onContribute;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progressColor = switch (item.tone) {
      GoalProgressTone.secondary => scheme.secondary,
      GoalProgressTone.tertiary => scheme.tertiary,
    };
    final pillBg = switch (item.tone) {
      GoalProgressTone.secondary => scheme.secondaryContainer.withValues(
        alpha: 0.35,
      ),
      GoalProgressTone.tertiary => scheme.tertiaryContainer.withValues(
        alpha: 0.22,
      ),
    };
    final pillFg = switch (item.tone) {
      GoalProgressTone.secondary => scheme.onSecondaryContainer,
      GoalProgressTone.tertiary => scheme.onTertiaryContainer,
    };
    final savedAccent = switch (item.tone) {
      GoalProgressTone.secondary => scheme.primary,
      GoalProgressTone.tertiary => scheme.tertiary,
    };

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            item.isSample
                ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('这是演示心愿，点上方「设立新目标」创建你自己的吧')),
                  );
                }
                : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GoalThumb(imageAsset: item.imageAsset, scheme: scheme),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.isCompleted
                                    ? '完成'
                                    : '${item.percentRounded}%',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color: pillFg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    formatCentsToYuan(item.savedCents),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: savedAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '目标 ${formatCentsToYuan(item.targetCents)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 28,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: scheme.surfaceContainerHigh),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: item.progress.clamp(0.0, 1.0),
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  progressColor.withValues(alpha: 0.85),
                                  progressColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.isSample) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '演示数据 · 不会动用你的虚拟余额',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: scheme.outline),
                  ),
                ),
              ],
              if (!item.isSample &&
                  !item.isCompleted &&
                  onContribute != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: onContribute,
                    child: const Text('从余额转入'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalThumb extends StatelessWidget {
  const _GoalThumb({required this.imageAsset, required this.scheme});

  final String? imageAsset;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    final borderRadius = BorderRadius.circular(12);
    if (imageAsset != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          imageAsset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackThumb(scheme, size),
        ),
      );
    }
    return _fallbackThumb(scheme, size);
  }

  Widget _fallbackThumb(ColorScheme scheme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.5),
            scheme.secondaryContainer.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Icon(Icons.stars_rounded, size: 40, color: scheme.primary),
    );
  }
}
