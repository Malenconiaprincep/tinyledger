import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/ledger_models.dart';
import '../domain/ledger_repository.dart';

class SqliteLedgerRepository implements LedgerRepository {
  SqliteLedgerRepository._({
    required Database database,
    required DatabaseExecutor executor,
  }) : _database = database,
       _exec = executor;

  final Database _database;
  final DatabaseExecutor _exec;

  static Future<SqliteLedgerRepository> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'tiny_ledger.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE ledger_transactions (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  category TEXT,
  note TEXT,
  goal_id TEXT,
  created_at INTEGER NOT NULL
);
''');
        await db.execute('''
CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_cents INTEGER NOT NULL,
  saved_cents INTEGER NOT NULL,
  completed_at INTEGER
);
''');
        await db.execute('''
CREATE TABLE meta (
  k TEXT PRIMARY KEY,
  v TEXT NOT NULL
);
''');
      },
    );
    return SqliteLedgerRepository._(database: db, executor: db);
  }

  @override
  Future<int> walletBalanceCents() async {
    final rows = await _exec.rawQuery(
      'SELECT COALESCE(SUM(amount_cents), 0) AS b FROM ledger_transactions',
    );
    return (rows.first['b'] as int?) ?? 0;
  }

  @override
  Future<List<LedgerTransaction>> listTransactions({int limit = 200}) async {
    final rows = await _exec.query(
      'ledger_transactions',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_rowToTx).toList();
  }

  @override
  Future<List<SavingsGoal>> listGoals() async {
    final rows = await _exec.query(
      'goals',
      orderBy: 'completed_at IS NULL DESC, name ASC',
    );
    return rows.map(_rowToGoal).toList();
  }

  @override
  Future<void> insertTransaction(LedgerTransaction tx) async {
    await _exec.insert('ledger_transactions', {
      'id': tx.id,
      'kind': tx.kind.wireName,
      'amount_cents': tx.signedAmountCents,
      'category': tx.category,
      'note': tx.note,
      'goal_id': tx.goalId,
      'created_at': tx.createdAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> upsertGoal(SavingsGoal goal) async {
    await _exec.insert('goals', {
      'id': goal.id,
      'name': goal.name,
      'target_cents': goal.targetCents,
      'saved_cents': goal.savedCents,
      'completed_at': goal.completedAt?.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<SavingsGoal?> getGoal(String id) async {
    final rows = await _exec.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToGoal(rows.first);
  }

  @override
  Future<String?> metaGet(String key) async {
    final rows = await _exec.query(
      'meta',
      where: 'k = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['v'] as String?;
  }

  @override
  Future<void> metaSet(String key, String value) async {
    await _exec.insert('meta', {
      'k': key,
      'v': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> runInTransaction(
    Future<void> Function(LedgerRepository scoped) action,
  ) async {
    await _database.transaction((txn) async {
      final scoped = SqliteLedgerRepository._(
        database: _database,
        executor: txn,
      );
      await action(scoped);
    });
  }

  @override
  Future<void> clearPracticeDataLocal() async {
    await _database.transaction((txn) async {
      await txn.delete('ledger_transactions');
      await txn.delete('goals');
      await txn.delete(
        'meta',
        where: 'k = ?',
        whereArgs: ['last_learning_bonus_ms'],
      );
    });
  }

  LedgerTransaction _rowToTx(Map<String, Object?> row) {
    return LedgerTransaction(
      id: row['id']! as String,
      kind: parseLedgerTxKind(row['kind']! as String),
      signedAmountCents: row['amount_cents']! as int,
      category: row['category'] as String?,
      note: row['note'] as String?,
      goalId: row['goal_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
    );
  }

  SavingsGoal _rowToGoal(Map<String, Object?> row) {
    final completedRaw = row['completed_at'] as int?;
    return SavingsGoal(
      id: row['id']! as String,
      name: row['name']! as String,
      targetCents: row['target_cents']! as int,
      savedCents: row['saved_cents']! as int,
      completedAt:
          completedRaw == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(completedRaw),
    );
  }
}
