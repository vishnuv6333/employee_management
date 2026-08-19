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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Soften color background for dark mode or contrast
    final cardBackgroundColor = isDark
        ? Color.alphaBlend(noteColor.withValues(alpha: 0.25), colorScheme.surfaceContainer)
        : Color.alphaBlend(noteColor.withValues(alpha: 0.4), colorScheme.surface);

    final completedChecklistCount = note.checklist.where((c) => c.isCompleted).length;
    final totalChecklistCount = note.checklist.length;
    final checklistProgress = totalChecklistCount > 0
        ? completedChecklistCount / totalChecklistCount
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: cardBackgroundColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push(AppRoutes.noteEditor, extra: note).then((_) {
              if (context.mounted) {
                context.read<NotesBloc>().add(LoadNotes());
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
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
                            note.title.isEmpty ? 'Untitled Note' : note.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 10),
                              Text('Edit Note'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 18),
                              SizedBox(width: 10),
                              Text('Archive Note'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              SizedBox(width: 10),
                              Text('Delete Note', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (note.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.description,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                if (totalChecklistCount > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: checklistProgress,
                            minHeight: 6,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$completedChecklistCount/$totalChecklistCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(note.updatedAt),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (note.images.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.image_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${note.images.length}',
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
