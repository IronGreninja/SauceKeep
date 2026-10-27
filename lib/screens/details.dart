import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../database/tables.dart';

class SauceDetailsPage extends ConsumerStatefulWidget {
  final Sauce sauce;

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
  bool _isLoadingTags = true;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.sauce.title;
    _titleController = .new(text: _currentTitle);
    _currentDesc = widget.sauce.description ?? '';
    _descController = .new(text: _currentDesc);
    _loadTags();
  }

  Future<void> _loadTags() async {
    final database = ref.read(AppDatabase.provider);

    final fetchedTags = await database.getSauceTags(widget.sauce.id);

    setState(() {
      _currentTagsStr = fetchedTags.join(', ');
      _currentTagNames = fetchedTags;
      _tagsController = .new(text: _currentTagsStr);
      _isLoadingTags = false;
    });
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
      sauceId: widget.sauce.id,
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final database = ref.read(AppDatabase.provider);
      await database.deleteSauceWithCleanup(widget.sauce.id);

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
                  id: widget.sauce.id,
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
        child: _isLoadingTags
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
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
                    const SizedBox(height: 24),
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
