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

  /// 清空本机练习数据：流水、目标，以及历史遗留的小金库周期 meta（若存在）。
  ///
  /// 保留设备级偏好（如减弱动效）、是否完成过引导等；不包含云同步逻辑。
  Future<void> clearPracticeDataLocal();
}
