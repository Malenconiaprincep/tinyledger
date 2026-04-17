import 'package:tiny_ledger/domain/ledger_models.dart';
import 'package:tiny_ledger/domain/ledger_repository.dart';

class FakeLedgerRepository implements LedgerRepository {
  final List<LedgerTransaction> transactions = [];
  final Map<String, SavingsGoal> goals = {};
  final Map<String, String> meta = {};

  @override
  Future<int> walletBalanceCents() async {
    return transactions.fold<int>(0, (sum, t) => sum + t.signedAmountCents);
  }

  @override
  Future<List<LedgerTransaction>> listTransactions({int limit = 200}) async {
    final sorted = [...transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<SavingsGoal>> listGoals() async => goals.values.toList();

  @override
  Future<void> insertTransaction(LedgerTransaction tx) async {
    transactions.add(tx);
  }

  @override
  Future<void> upsertGoal(SavingsGoal goal) async {
    goals[goal.id] = goal;
  }

  @override
  Future<SavingsGoal?> getGoal(String id) async => goals[id];

  @override
  Future<String?> metaGet(String key) async => meta[key];

  @override
  Future<void> metaSet(String key, String value) async {
    meta[key] = value;
  }

  @override
  Future<void> runInTransaction(
    Future<void> Function(LedgerRepository scoped) action,
  ) async {
    await action(this);
  }

  @override
  Future<void> clearPracticeDataLocal() async {
    transactions.clear();
    goals.clear();
    meta.remove('last_learning_bonus_ms');
  }
}
