import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/onboarding_page.dart';
import '../providers.dart';
import 'app_shell.dart';
import 'tiny_ledger_theme.dart';

class TinyLedgerApp extends ConsumerWidget {
  const TinyLedgerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingDoneProvider);
    return MaterialApp(
      title: '小算盘',
      theme: buildTinyLedgerTheme(),
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final userReduce = ref
                .watch(reduceMotionUserProvider)
                .maybeWhen(data: (v) => v, orElse: () => false);
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                disableAnimations: mq.disableAnimations || userReduce,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      home: onboarding.when(
        data: (done) => done ? const AppShell() : const OnboardingPage(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (e, st) => Scaffold(body: Center(child: Text('启动失败：$e'))),
      ),
    );
  }
}
