import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection_container.dart' as di;
import '../../../../../core/notifications/notification_service.dart';

import '../bloc/note_editor_bloc.dart';
import '../bloc/note_editor_event.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';

class NoteEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSave;

  const NoteEditorAppBar({super.key, required this.onSave});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NoteEditorBloc>().state;

    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && context.mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: false),
                    child: child!,
                  );
                },
              );
              if (time != null && context.mounted) {
                final scheduledDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                context.read<NoteEditorBloc>().add(MarkDirty());

                final noteForReminder = state
                    .copyWith(
                      title: state.title.trim().isEmpty
                          ? 'New Note'
                          : state.title.trim(),
                    )
                    .toNote();

                di.sl<NotificationService>().scheduleNoteReminder(
                  noteForReminder,
                  scheduledDate,
                );
                if (context.mounted) {
                  final hour = time.hour == 0
                      ? 12
                      : (time.hour > 12 ? time.hour - 12 : time.hour);
                  final minute = time.minute.toString().padLeft(2, '0');
                  final period = time.hour >= 12 ? 'PM' : 'AM';
                  final timeString = '$hour:$minute $period';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Note Reminder set for ${date.month}/${date.day}/${date.year} at $timeString',
                      ),
                    ),
                  );
                }
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            context.read<NotesBloc>().add(DeleteNote(state.noteId));
            context.pop();
          },
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            onSave();
            context.pop();
          },
        ),
      ],
    );
  }
}
