import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/tiny_ledger_app.dart';
import 'data/sqlite_ledger_repository.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await SqliteLedgerRepository.open();
  runApp(
    ProviderScope(
      overrides: [ledgerRepositoryProvider.overrideWithValue(repo)],
      child: const TinyLedgerApp(),
    ),
  );
}
