import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;

  const NoteCardWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    Color noteColor = Colors.white;
    try {
      noteColor = Color(int.parse(note.color.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Card(
      color: noteColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.noteEditor, extra: note).then((_) {
            if (context.mounted) {
              context.read<NotesBloc>().add(LoadNotes());
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'note_title_${note.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          note.title.isEmpty ? 'Untitled' : note.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push(AppRoutes.noteEditor, extra: note).then((_) {
                          if (context.mounted) {
                            context.read<NotesBloc>().add(LoadNotes());
                          }
                        });
                      } else if (value == 'archive') {
                        context.read<NotesBloc>().add(ArchiveNote(note.id));
                      } else if (value == 'delete') {
                        context.read<NotesBloc>().add(DeleteNote(note.id));
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Note'),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive Note'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Note'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.updatedAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      if (note.checklist.isNotEmpty) ...[
                        const Icon(
                          Icons.check_box_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.checklist.where((c) => c.isCompleted).length}/${note.checklist.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
