enum LedgerTxKind { income, expense, goalContribution, learningBonus }

extension LedgerTxKindWire on LedgerTxKind {
  String get wireName => switch (this) {
    LedgerTxKind.income => 'income',
    LedgerTxKind.expense => 'expense',
    LedgerTxKind.goalContribution => 'goal_contribution',
    LedgerTxKind.learningBonus => 'learning_bonus',
  };
}

LedgerTxKind parseLedgerTxKind(String raw) => switch (raw) {
  'income' => LedgerTxKind.income,
  'expense' => LedgerTxKind.expense,
  'goal_contribution' => LedgerTxKind.goalContribution,
  'learning_bonus' => LedgerTxKind.learningBonus,
  _ => LedgerTxKind.expense,
};

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.kind,
    required this.signedAmountCents,
    required this.createdAt,
    this.category,
    this.note,
    this.goalId,
  });

  final String id;
  final LedgerTxKind kind;

  /// 入账/奖励为正；支出与转入目标为负。
  final int signedAmountCents;
  final String? category;
  final String? note;
  final DateTime createdAt;
  final String? goalId;
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetCents,
    required this.savedCents,
    this.completedAt,
  });

  final String id;
  final String name;
  final int targetCents;
  final int savedCents;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null || savedCents >= targetCents;

  double get progress =>
      targetCents <= 0 ? 0 : (savedCents / targetCents).clamp(0, 1).toDouble();
}

/// 收入分类（对齐「记一笔 - iOS 温馨版」常见选项）。
const List<String> kIncomeCategories = ['零花钱', '礼物', '玩具', '零食'];

const List<String> kExpenseCategories = ['零食', '文具', '游戏', '礼物', '未分类'];
