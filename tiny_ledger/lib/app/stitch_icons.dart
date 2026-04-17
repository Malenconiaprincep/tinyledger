import 'package:flutter/material.dart';

import '../domain/ledger_models.dart';

/// 与 Stitch「iOS 温馨版」HTML 中 `material-symbols-outlined` 名称尽量对齐的图标映射。
IconData stitchTabAssetIcon({required bool selected}) =>
    selected
        ? Icons.account_balance_wallet
        : Icons.account_balance_wallet_outlined;

IconData stitchTabGoalsIcon({required bool selected}) =>
    selected ? Icons.stars_rounded : Icons.stars_outlined;

IconData stitchTabLedgerIcon({required bool selected}) =>
    selected ? Icons.receipt_long : Icons.receipt_long_outlined;

IconData stitchTabLearnIcon({required bool selected}) =>
    selected ? Icons.school_rounded : Icons.school_outlined;

IconData stitchTabSettingsIcon({required bool selected}) =>
    selected ? Icons.settings : Icons.settings_outlined;

IconData stitchIncomeCategoryIcon(String category) {
  return switch (category) {
    '零花钱' => Icons.account_balance_wallet_outlined,
    '礼物' => Icons.redeem_outlined,
    '玩具' => Icons.toys_outlined,
    '零食' => Icons.restaurant_outlined,
    _ => Icons.savings_outlined,
  };
}

IconData stitchExpenseCategoryIcon(String category) {
  return switch (category) {
    '零食' => Icons.restaurant_outlined,
    '文具' => Icons.edit_note_outlined,
    '游戏' => Icons.sports_esports_outlined,
    '礼物' => Icons.card_giftcard_outlined,
    '未分类' => Icons.category_outlined,
    _ => Icons.more_horiz,
  };
}

IconData stitchCategoryIcon({required bool income, String? category}) {
  final c = category ?? '';
  if (income) {
    if (c.isEmpty || !kIncomeCategories.contains(c)) {
      return Icons.payments_outlined;
    }
    return stitchIncomeCategoryIcon(c);
  }
  if (c.isEmpty || !kExpenseCategories.contains(c)) {
    return stitchExpenseCategoryIcon('未分类');
  }
  return stitchExpenseCategoryIcon(c);
}

IconData stitchLedgerTxIcon(LedgerTransaction tx) {
  return switch (tx.kind) {
    LedgerTxKind.income => stitchCategoryIcon(
      income: true,
      category: tx.category,
    ),
    LedgerTxKind.expense => stitchCategoryIcon(
      income: false,
      category: tx.category,
    ),
    LedgerTxKind.goalContribution => Icons.stars_rounded,
    LedgerTxKind.learningBonus => Icons.card_giftcard_outlined,
  };
}
