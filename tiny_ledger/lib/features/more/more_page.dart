import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../parent/parent_placeholder_page.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduce = ref.watch(reduceMotionUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('更多')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('关于广告'),
            subtitle: Text('小算盘的核心记账流程不包含第三方广告或外链营销（产品约束）。'),
          ),
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
          ListTile(
            title: const Text('家长可见摘要（占位）'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ParentPlaceholderPage(),
                ),
              );
            },
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
