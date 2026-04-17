import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/ledger_models.dart';
import 'domain/ledger_repository.dart';
import 'domain/ledger_service.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  throw UnimplementedError(
    'ledgerRepositoryProvider must be overridden in ProviderScope',
  );
});

final ledgerServiceProvider = Provider<LedgerService>((ref) {
  return LedgerService(ref.watch(ledgerRepositoryProvider));
});

final ledgerRefreshProvider = StateProvider<int>((ref) => 0);

class LedgerSnapshot {
  LedgerSnapshot({
    required this.balanceCents,
    required this.transactions,
    required this.goals,
  });

  final int balanceCents;
  final List<LedgerTransaction> transactions;
  final List<SavingsGoal> goals;
}

final ledgerSnapshotProvider = FutureProvider.autoDispose<LedgerSnapshot>((
  ref,
) async {
  ref.watch(ledgerRefreshProvider);
  final svc = ref.watch(ledgerServiceProvider);
  final balance = await svc.walletBalanceCents();
  final txs = await svc.listTransactions();
  final goals = await svc.listGoals();
  return LedgerSnapshot(balanceCents: balance, transactions: txs, goals: goals);
});

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return (await repo.metaGet('onboarding_done')) == '1';
});

final reduceMotionUserProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return (await repo.metaGet('user_reduce_motion')) == '1';
});

void bumpLedger(WidgetRef ref) {
  ref.read(ledgerRefreshProvider.notifier).state++;
}
