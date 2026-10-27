import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../database/tables.dart';

class SauceAddDialog extends ConsumerStatefulWidget {
  const SauceAddDialog({super.key});

  @override
  ConsumerState<SauceAddDialog> createState() => _SauceAddDialogState();
}

class _SauceAddDialogState extends ConsumerState<SauceAddDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    _titleController = .new();
    _descController = .new();
    _tagsController = .new();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addSauceItem() async {
    if (_titleController.text.isEmpty) {
      if (mounted) {
        // fixme: snackbar looks ugly here
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title cannot be empty')),
        );
      }
      return;
    }

    final database = ref.read(AppDatabase.provider);
    await database.createSauceWithTags(
      title: _titleController.text,
      tagNames: Tags.namesListFromCommaSepStrOfNames(_tagsController.text),
      desc: _descController.text.isEmpty ? null : _descController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauce updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new sauce'),
      content: Column(
        mainAxisSize: .min,
        children: [
          _mkTextField(_titleController, 'Title', 'Bechamel'),
          _mkTextField(_descController, 'Description', 'For white sauce pasta'),
          _mkTextField(
            _tagsController,
            'Tags (comma-separated)',
            'pasta, creamy',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            _addSauceItem();
          },
        ),
      ],
    );
  }
}

Widget _mkTextField(TextEditingController c, String helper, String hint) =>
    TextField(
      controller: c,
      decoration: InputDecoration(helperText: helper, hintText: hint),
    );
