import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('欢迎来到小算盘', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                '这是给 8–10 岁小朋友用的「虚拟」记账本：里面的钱不是真钱，用来练习储蓄、花钱和定小目标。',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.35),
              ),
              const SizedBox(height: 12),
              Text(
                '请和家长一起使用：遇到不懂的词，可以问问大人。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(ledgerRepositoryProvider)
                        .metaSet('onboarding_done', '1');
                    ref.invalidate(onboardingDoneProvider);
                  },
                  child: const Text('我知道了，开始使用'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
