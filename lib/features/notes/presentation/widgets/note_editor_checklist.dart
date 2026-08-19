import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note.dart';
import '../bloc/note_editor_bloc.dart';
import '../bloc/note_editor_event.dart';
import '../bloc/note_editor_state.dart';

class NoteEditorChecklist extends StatelessWidget {
  const NoteEditorChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteEditorBloc, NoteEditorState>(
      buildWhen: (previous, current) => previous.checklist != current.checklist,
      builder: (context, state) {
        if (state.checklist.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const Text(
              'Checklist',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...state.checklist.asMap().entries.map((entry) {
              int idx = entry.key;
              ChecklistItem item = entry.value;
              return CheckboxListTile(
                title: Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                value: item.isCompleted,
                onChanged: (val) {
                  context.read<NoteEditorBloc>().add(
                    ChecklistItemUpdated(
                      idx,
                      ChecklistItem(
                        title: item.title,
                        isCompleted: val ?? false,
                      ),
                    ),
                  );
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    context.read<NoteEditorBloc>().add(
                      ChecklistItemRemoved(idx),
                    );
                  },
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        );
      },
    );
  }
}
