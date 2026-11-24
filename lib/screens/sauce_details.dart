import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../database/tables.dart';

class SauceDetailsPage extends ConsumerStatefulWidget {
  final SauceWithTags sauce;

  const SauceDetailsPage({super.key, required this.sauce});

  @override
  ConsumerState<SauceDetailsPage> createState() => _SauceDetailsPageState();
}

class _SauceDetailsPageState extends ConsumerState<SauceDetailsPage> {
  bool _isEditing = false;

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _tagsController;

  late String _currentTitle;
  late String _currentDesc;
  late String _currentTagsStr;

  List<String> _currentTagNames = [];

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.sauce.sauce.title;
    _titleController = .new(text: _currentTitle);
    _currentDesc = widget.sauce.sauce.description ?? '';
    _descController = .new(text: _currentDesc);
    _currentTagNames = widget.sauce.tags;
    _currentTagsStr = _currentTagNames.join(', ');
    _tagsController = .new(text: _currentTagsStr);
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title cannot be empty')),
        );
      }
      return;
    }

    final desc = _descController.text.trim();
    final tagNames = Tags.namesListFromCommaSepStrOfNames(_tagsController.text);

    final database = ref.read(AppDatabase.provider);
    await database.updateSauceWithTags(
      sauceId: widget.sauce.sauce.id,
      title: title,
      desc: desc.isEmpty ? null : desc,
      tagNames: tagNames,
    );

    setState(() {
      _isEditing = false;
      _currentTitle = title;
      _currentDesc = desc;
      _currentTagsStr = tagNames.join(', ');
      _currentTagNames = tagNames;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauce updated successfully')),
      );
    }
  }

  Future<void> _deleteSauce() async {
    // confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sauce'),
        content: Text(
          'Are you sure you want to delete "$_currentTitle"?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final database = ref.read(AppDatabase.provider);
      await database.deleteSauceWithCleanup(widget.sauce.sauce.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "$_currentTitle"'),
            duration: const Duration(
              seconds: 4,
            ), // needs persist: false to work
            // persist: false,
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                // Re-insert the sauce and its tags if user clicks Undo
                await database.createSauceWithTags(
                  id: widget.sauce.sauce.id,
                  title: _currentTitle,
                  desc: _currentDesc.isEmpty ? null : _currentDesc,
                  tagNames: _currentTagNames,
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Sauce' : 'Sauce Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            tooltip: _isEditing ? 'Save' : 'Edit',
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.delete),
            tooltip: _isEditing ? 'Cancel' : 'Delete',
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  _isEditing = false;

                  // revert fields to initial
                  _titleController.text = _currentTitle;
                  _descController.text = _currentDesc;
                  _tagsController.text = _currentTagsStr;
                });
              } else {
                _deleteSauce();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Text(
                  'Created ${MaterialLocalizations.of(context).formatMediumDate(widget.sauce.sauce.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              enabled: _isEditing,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              TextField(
                controller: _tagsController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
            if (!_isEditing) ...[
              const Text(
                'Associated Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _currentTagNames
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
