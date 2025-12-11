import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_cubit.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_state.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

/// Tag Management Screen
/// Allows users to view, create, delete, and merge tags.
class TagManagementPage extends StatefulWidget {
  const TagManagementPage({super.key});

  @override
  State<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends State<TagManagementPage> {
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load tags when page initializes
    context.read<TagCubit>().loadAllTags();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  void _showCreateTagDialog() {
    _newTagController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Tag'),
          content: TextField(
            controller: _newTagController,
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _newTagController.text.trim();
                if (name.isNotEmpty) {
                  context.read<TagCubit>().createTag(name);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showMergeTagDialog(Tag sourceTag, List<Tag> allTags) {
    Tag? mergeTargetTag;

    final availableTags = allTags.where((t) => t.id != sourceTag.id).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Merge Tags'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Merge "${sourceTag.name}" into:'),
                  const SizedBox(height: 16),
                  DropdownButton<Tag>(
                    isExpanded: true,
                    hint: const Text('Select target tag'),
                    value: mergeTargetTag,
                    items: availableTags.map((Tag tagOption) {
                      return DropdownMenuItem<Tag>(
                        value: tagOption,
                        child: Text(tagOption.name),
                      );
                    }).toList(),
                    onChanged: (Tag? newValue) {
                      setState(() {
                        mergeTargetTag = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: mergeTargetTag != null
                      ? () {
                          context.read<TagCubit>().mergeTags(
                                sourceTag.id,
                                mergeTargetTag!.id,
                              );
                          Navigator.pop(dialogContext);
                        }
                      : null,
                  child: const Text('Merge'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Tag tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tag'),
          content: Text(
            'Are you sure you want to delete "${tag.name}"? '
            'This will remove the tag from all sheets.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TagCubit>().deleteTag(tag.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
        elevation: 0,
      ),
      body: BlocBuilder<TagCubit, TagState>(
        builder: (context, state) {
          return state.when(
            idle: () => _buildIdleState(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _buildErrorState(message, context),
            loaded: (tags) => _buildLoadedState(tags),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTagDialog,
        tooltip: 'Create new tag',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIdleState() {
    return const Center(
      child: Text('Ready to manage tags'),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TagCubit>().loadAllTags(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<Tag> tags) {
    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tags created yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateTagDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create First Tag'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(tag.count.toString()),
            ),
            title: Text(tag.name),
            subtitle:
                Text('Used in ${tag.count} sheet${tag.count != 1 ? 's' : ''}'),
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: const Text('Merge'),
                  onTap: () {
                    // Delay to allow menu to close
                    Future.delayed(Duration.zero, () {
                      _showMergeTagDialog(tag, tags);
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    // Delay to allow menu to close
                    Future.delayed(Duration.zero, () {
                      _showDeleteConfirmation(tag);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
