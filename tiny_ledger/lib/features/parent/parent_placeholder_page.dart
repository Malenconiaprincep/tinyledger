import 'package:flutter/material.dart';

class ParentPlaceholderPage extends StatelessWidget {
  const ParentPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家长可见摘要')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '这里是「家长可见摘要」占位页：首版仅说明未来可展示的非敏感汇总（例如本周记账次数）。\n\n当前不收集敏感个人信息，也不连接真实银行账户。',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.35),
        ),
      ),
    );
  }
}
