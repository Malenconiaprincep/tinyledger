import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_header.dart';
import 'stitch_icons.dart';
import '../features/goals/goals_page.dart';
import '../features/growth/growth_page.dart';
import '../features/home/home_page.dart';
import '../features/ledger/ledger_list_page.dart';
import '../features/more/more_page.dart';
import '../providers.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _pages = <Widget>[
    HomePage(),
    GoalsPage(),
    LedgerListPage(),
    GrowthPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(appShellTabIndexProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: scheme.surfaceContainerLowest,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                    child: const TinyLedgerAppHeader(),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.22),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _pages[index]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) {
                ref.read(appShellTabIndexProvider.notifier).state = i;
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(stitchTabAssetIcon(selected: false)),
                  selectedIcon: Icon(stitchTabAssetIcon(selected: true)),
                  label: '资产',
                ),
                NavigationDestination(
                  icon: Icon(stitchTabGoalsIcon(selected: false)),
                  selectedIcon: Icon(stitchTabGoalsIcon(selected: true)),
                  label: '目标',
                ),
                NavigationDestination(
                  icon: Icon(stitchTabLedgerIcon(selected: false)),
                  selectedIcon: Icon(stitchTabLedgerIcon(selected: true)),
                  label: '账本',
                ),
                NavigationDestination(
                  icon: Icon(stitchTabLearnIcon(selected: false)),
                  selectedIcon: Icon(stitchTabLearnIcon(selected: true)),
                  label: '小金库',
                ),
                NavigationDestination(
                  icon: Icon(stitchTabSettingsIcon(selected: false)),
                  selectedIcon: Icon(stitchTabSettingsIcon(selected: true)),
                  label: '设置',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
