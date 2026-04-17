import 'ledger_models.dart';

abstract class LedgerRepository {
  Future<int> walletBalanceCents();

  Future<List<LedgerTransaction>> listTransactions({int limit = 200});

  Future<List<SavingsGoal>> listGoals();

  Future<void> insertTransaction(LedgerTransaction tx);

  Future<void> upsertGoal(SavingsGoal goal);

  Future<SavingsGoal?> getGoal(String id);

  Future<String?> metaGet(String key);

  Future<void> metaSet(String key, String value);

  /// 在原子事务内执行；回调入参为「同一连接上的仓储视图」，必须在其中完成读写。
  Future<void> runInTransaction(
    Future<void> Function(LedgerRepository scoped) action,
  );
}
