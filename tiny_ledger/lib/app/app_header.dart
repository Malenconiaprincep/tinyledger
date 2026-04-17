import 'package:flutter/material.dart';

/// 首页顶栏品牌行（对齐「首页/资产 - iOS 温馨版」信息架构：头像 / 品牌 / 通知占位）。
class TinyLedgerAppHeader extends StatelessWidget {
  const TinyLedgerAppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primaryContainer.withValues(alpha: 0.45),
            child: Icon(Icons.person_outline, color: scheme.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'TinyLedger',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
                letterSpacing: -0.03,
              ),
            ),
          ),
          IconButton(
            tooltip: '通知（占位）',
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }
}
