import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/note.dart';
import '../bloc/note_editor_bloc.dart';
import '../bloc/note_editor_event.dart';

class NoteEditorBottomBar extends StatelessWidget {
  const NoteEditorBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Add Checklist Item',
            onPressed: () {
              _showAddChecklistDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Add Image',
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null && context.mounted) {
                context.read<NoteEditorBloc>().add(ImageAdded(image.path));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddChecklistDialog(BuildContext context) {
    final TextEditingController checklistController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Checklist Item'),
          content: TextField(
            controller: checklistController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Item description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (checklistController.text.trim().isNotEmpty) {
                  context.read<NoteEditorBloc>().add(
                    ChecklistItemAdded(
                      ChecklistItem(
                        title: checklistController.text.trim(),
                        isCompleted: false,
                      ),
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
