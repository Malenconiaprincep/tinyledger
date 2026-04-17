import 'package:uuid/uuid.dart';

import 'ledger_models.dart';
import 'ledger_repository.dart';

class LedgerException implements Exception {
  LedgerException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LedgerService {
  LedgerService(this._repo, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final LedgerRepository _repo;
  final Uuid _uuid;

  Future<int> walletBalanceCents() => _repo.walletBalanceCents();

  Future<List<LedgerTransaction>> listTransactions() =>
      _repo.listTransactions();

  Future<List<SavingsGoal>> listGoals() => _repo.listGoals();

  Future<void> addIncome({
    required int amountCents,
    String note = '',
    String? category,
    DateTime? recordedAt,
  }) async {
    if (amountCents <= 0) throw LedgerException('入账金额必须大于 0');
    final at = recordedAt ?? DateTime.now();
    await _repo.insertTransaction(
      LedgerTransaction(
        id: _uuid.v4(),
        kind: LedgerTxKind.income,
        signedAmountCents: amountCents,
        createdAt: at,
        category: category,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  Future<void> addExpense({
    required int amountCents,
    String? category,
    String note = '',
    DateTime? recordedAt,
  }) async {
    if (amountCents <= 0) throw LedgerException('支出金额必须大于 0');
    final balance = await _repo.walletBalanceCents();
    if (balance < amountCents) {
      throw LedgerException('余额不足，无法记录这笔支出');
    }
    final at = recordedAt ?? DateTime.now();
    await _repo.insertTransaction(
      LedgerTransaction(
        id: _uuid.v4(),
        kind: LedgerTxKind.expense,
        signedAmountCents: -amountCents,
        category: category ?? '未分类',
        note: note.isEmpty ? null : note,
        createdAt: at,
      ),
    );
  }

  Future<SavingsGoal> createGoal({
    required String name,
    required int targetCents,
  }) async {
    if (name.trim().isEmpty) throw LedgerException('目标名称不能为空');
    if (targetCents <= 0) throw LedgerException('目标金额必须大于 0');
    final goal = SavingsGoal(
      id: _uuid.v4(),
      name: name.trim(),
      targetCents: targetCents,
      savedCents: 0,
    );
    await _repo.upsertGoal(goal);
    return goal;
  }

  Future<void> contributeToGoal({
    required String goalId,
    required int amountCents,
  }) async {
    if (amountCents <= 0) throw LedgerException('转入金额必须大于 0');
    await _repo.runInTransaction((scoped) async {
      final balance = await scoped.walletBalanceCents();
      if (balance < amountCents) {
        throw LedgerException('余额不足，无法转入目标');
      }
      final goal = await scoped.getGoal(goalId);
      if (goal == null) throw LedgerException('目标不存在');
      if (goal.isCompleted) throw LedgerException('目标已完成，无法继续转入');

      final newSaved = goal.savedCents + amountCents;
      final completedAt = newSaved >= goal.targetCents ? DateTime.now() : null;

      await scoped.insertTransaction(
        LedgerTransaction(
          id: _uuid.v4(),
          kind: LedgerTxKind.goalContribution,
          signedAmountCents: -amountCents,
          createdAt: DateTime.now(),
          goalId: goalId,
          note: '转入目标：${goal.name}',
        ),
      );

      await scoped.upsertGoal(
        SavingsGoal(
          id: goal.id,
          name: goal.name,
          targetCents: goal.targetCents,
          savedCents: newSaved,
          completedAt: completedAt ?? goal.completedAt,
        ),
      );
    });
  }

  /// 学习奖励：仅使用应用内规则（固定金额 + 周期间隔），不访问外部市场。
  Future<bool> tryApplyLearningBonus({
    required int bonusAmountCents,
    required int intervalDays,
  }) async {
    if (bonusAmountCents <= 0) return false;
    if (intervalDays <= 0) return false;

    final lastRaw = await _repo.metaGet('last_learning_bonus_ms');
    final now = DateTime.now();
    if (lastRaw != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(int.parse(lastRaw));
      if (now.difference(last).inDays < intervalDays) {
        return false;
      }
    }

    await _repo.runInTransaction((scoped) async {
      await scoped.insertTransaction(
        LedgerTransaction(
          id: _uuid.v4(),
          kind: LedgerTxKind.learningBonus,
          signedAmountCents: bonusAmountCents,
          createdAt: now,
          note: '学习用周期奖励（模拟）',
        ),
      );
      await scoped.metaSet(
        'last_learning_bonus_ms',
        '${now.millisecondsSinceEpoch}',
      );
    });
    return true;
  }
}
