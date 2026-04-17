import 'package:test/test.dart';
import 'package:tiny_ledger/domain/ledger_service.dart';
import 'package:uuid/uuid.dart';

import 'fakes/fake_ledger_repository.dart';

void main() {
  test('addIncome increases balance', () async {
    final repo = FakeLedgerRepository();
    final svc = LedgerService(repo);
    await svc.addIncome(amountCents: 1000, note: '零花钱');
    expect(await svc.walletBalanceCents(), 1000);
  });

  test('addIncome stores category and recordedAt', () async {
    final repo = FakeLedgerRepository();
    final svc = LedgerService(repo, uuid: const Uuid());
    final at = DateTime(2024, 6, 1, 12);
    await svc.addIncome(
      amountCents: 200,
      category: '零花钱',
      recordedAt: at,
    );
    final txs = await svc.listTransactions();
    expect(txs.single.category, '零花钱');
    expect(txs.single.createdAt, at);
  });

  test('addExpense rejects overspend', () async {
    final repo = FakeLedgerRepository();
    final svc = LedgerService(repo);
    await svc.addIncome(amountCents: 500);
    expect(
      () => svc.addExpense(amountCents: 501, category: '未分类'),
      throwsA(isA<LedgerException>()),
    );
  });

  test('contributeToGoal moves money and completes', () async {
    final repo = FakeLedgerRepository();
    final svc = LedgerService(repo, uuid: const Uuid());
    await svc.addIncome(amountCents: 10_000);
    final goal = await svc.createGoal(name: '买书', targetCents: 3000);
    await svc.contributeToGoal(goalId: goal.id, amountCents: 3000);
    final goals = await svc.listGoals();
    final updated = goals.firstWhere((g) => g.id == goal.id);
    expect(updated.savedCents, 3000);
    expect(updated.isCompleted, isTrue);
  });

  test('clearPracticeDataLocal wipes tx and goals, keeps meta prefs', () async {
    final repo = FakeLedgerRepository();
    final svc = LedgerService(repo, uuid: const Uuid());
    await svc.addIncome(amountCents: 500, category: '零花钱');
    await repo.metaSet('user_reduce_motion', '1');
    await repo.metaSet('onboarding_done', '1');
    await svc.createGoal(name: '书', targetCents: 1000);
    await repo.clearPracticeDataLocal();
    expect(await svc.walletBalanceCents(), 0);
    expect(await svc.listTransactions(), isEmpty);
    expect(await svc.listGoals(), isEmpty);
    expect(await repo.metaGet('user_reduce_motion'), '1');
    expect(await repo.metaGet('onboarding_done'), '1');
  });
}
