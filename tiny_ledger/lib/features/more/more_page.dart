import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tiny_ledger_theme.dart';
import '../../providers.dart';
import '../parent/parent_placeholder_page.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduce = ref.watch(reduceMotionUserProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Material(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer.withValues(
                    alpha: 0.45,
                  ),
                  child: Icon(Icons.face_outlined, color: scheme.primary),
                ),
                title: const Text('小小记账员'),
                subtitle: const Text('虚拟练习 · 非真实资金'),
              ),
            ),
          ),
          _SectionHeader(title: '体验与无障碍', scheme: scheme),
          reduce.when(
            loading: () => const ListTile(title: Text('加载设置…')),
            error: (e, _) => ListTile(title: Text('设置加载失败：$e')),
            data: (userReduce) {
              return SwitchListTile(
                title: const Text('减弱动效（应用内）'),
                subtitle: const Text('也会尊重系统的「减少动画」设置。'),
                value: userReduce,
                onChanged: (v) async {
                  await ref
                      .read(ledgerRepositoryProvider)
                      .metaSet('user_reduce_motion', v ? '1' : '0');
                  ref.invalidate(reduceMotionUserProvider);
                },
              );
            },
          ),
          _SectionHeader(title: '儿童与家长', scheme: scheme),
          ListTile(
            title: const Text('适龄说明'),
            subtitle: const Text('与首次使用前说明一致，可随时复习。'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder:
                    (ctx) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.55,
                      minChildSize: 0.35,
                      maxChildSize: 0.9,
                      builder:
                          (_, scroll) => SingleChildScrollView(
                            controller: scroll,
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '适龄说明',
                                  style: Theme.of(ctx).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '这是给 8–10 岁小朋友用的「虚拟」记账本：里面的钱不是真钱，用来练习储蓄、花钱、定小目标和认识「增值」的小知识。',
                                  style: Theme.of(
                                    ctx,
                                  ).textTheme.bodyLarge?.copyWith(height: 1.35),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '请和家长一起使用：遇到不懂的词，可以问问大人。',
                                  style: Theme.of(
                                    ctx,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        Theme.of(
                                          ctx,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('关闭'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
              );
            },
          ),
          ListTile(
            title: const Text('家长可见摘要（占位）'),
            subtitle: const Text('未来可展示非敏感汇总，如本周储蓄次数。'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const ParentPlaceholderPage(),
                ),
              );
            },
          ),
          _SectionHeader(title: '关于产品', scheme: scheme),
          const ListTile(
            title: Text('关于广告'),
            subtitle: Text('小算盘的核心记账流程不包含第三方广告或外链营销（产品约束）。'),
          ),
          const ListTile(
            title: Text('上架说明草稿'),
            subtitle: Text('见 tiny_ledger/docs/STORE_LISTING.md'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.scheme});

  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
