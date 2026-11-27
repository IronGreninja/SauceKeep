import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../database/database.dart';

final databaseProvider = NotifierProvider<_DbNotifier, AppDatabase>(
  _DbNotifier.new,
);

class _DbNotifier extends Notifier<AppDatabase> {
  @override
  AppDatabase build() {
    final database = AppDatabase();
    ref.onDispose(database.close);

    return database;
  }

  Future<void> restoreDbFromFile(PlatformFile restoreFile) async {
    final restoreDb = sqlite3.open(restoreFile.path!);

    // Vacuum it into temp location to make sure it is working
    final tempDir = await getTemporaryDirectory();
    final tempDbPath = p.join(tempDir.path, 'tmp_restore.db');
    restoreDb
      ..execute('VACUUM INTO ?', [tempDbPath])
      ..close();

    // Replace the existing database file with it;
    await state.close(); // close original before restoring
    final tempDbFile = File(tempDbPath);
    await tempDbFile.copy((await databaseFile).path);
    await tempDbFile.delete();

    // Reopen newly restored database
    state = .new();
  }
}
