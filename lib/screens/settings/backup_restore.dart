import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/database.dart';
import '../../database/database.dart';

class BackupRestoreSettings extends ConsumerWidget {
  const BackupRestoreSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('Create backup'),
              onTap: () async {
                await createBackup(ref.read(databaseProvider));
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Restore backup'),
              onTap: () async {
                await restoreFromBackup(ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: if user cancelled, these return false.
// indicate it in the ui
Future<bool> createBackup(AppDatabase db) async {
  final bytes = await db.dbBackupFileBytes();

  // Let user choose filename and destination.
  final savePath = await FilePicker.saveFile(
    fileName: 'saucekeep_backup.sqlite',
    bytes: bytes,
  );

  if (savePath == null) return false;
  return true;
}

Future<bool> restoreFromBackup(WidgetRef ref) async {
  // Let user choose db file path to restore from
  final restoreFile = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['sqlite'],
  );
  if (restoreFile == null) return false;

  await ref.read(databaseProvider.notifier).restoreDbFromFile(restoreFile);

  return true;
}
