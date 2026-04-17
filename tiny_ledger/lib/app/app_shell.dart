import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      body: _pages[index],
      bottomNavigationBar: NavigationBar(
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
            label: '学习',
          ),
          NavigationDestination(
            icon: Icon(stitchTabSettingsIcon(selected: false)),
            selectedIcon: Icon(stitchTabSettingsIcon(selected: true)),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
