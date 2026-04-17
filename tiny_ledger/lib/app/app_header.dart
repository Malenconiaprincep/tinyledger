import 'package:flutter/material.dart';

/// 顶栏品牌行（Stitch **首页/资产 - 趣味探索版**：探险风头像 + 斜体品牌字）。
class TinyLedgerAppHeader extends StatelessWidget {
  const TinyLedgerAppHeader({
    super.key,
    this.brandLabel = 'TinyLedger',
    this.trailing,
  });

  /// 顶栏主标题（默认品牌名；子页可改为如「梦想金库」）。
  final String brandLabel;

  /// 右侧操作；默认占位通知按钮。
  final Widget? trailing;

  static const _avatarAsset = 'assets/images/stitch_playful_avatar.png';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.22),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                _avatarAsset,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => ColoredBox(
                      color: scheme.primaryContainer.withValues(alpha: 0.45),
                      child: Icon(Icons.person_outline, color: scheme.primary),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              brandLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: scheme.primary,
                letterSpacing: -0.04,
              ),
            ),
          ),
          trailing ??
              IconButton(
                tooltip: '通知（占位）',
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: scheme.surfaceContainerHigh,
                  foregroundColor: scheme.primary,
                  padding: const EdgeInsets.all(10),
                  minimumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.notifications_rounded, size: 22),
              ),
        ],
      ),
    );
  }
}
