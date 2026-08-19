import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';

class ArchivedNoteCardWidget extends StatelessWidget {
  final Note note;

  const ArchivedNoteCardWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    Color noteColor = Colors.white;
    try {
      noteColor = Color(int.parse(note.color.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Card(
      color: noteColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.noteEditor, extra: note).then((_) {
            if (context.mounted) {
              context.read<NotesBloc>().add(LoadArchivedNotes());
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (note.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
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
                      if (note.images.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.image, size: 16, color: Colors.grey),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.unarchive),
                  label: const Text('Unarchive'),
                  onPressed: () {
                    final updatedNote = note.copyWith(isArchived: false);
                    context.read<NotesBloc>().add(UpdateNote(updatedNote));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
