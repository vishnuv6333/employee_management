import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../../domain/entities/note.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<NotesBloc>()..add(LoadNotes()),
      child: const NotesView(),
    );
  }
}

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search').then((_) {
                // ignore: use_build_context_synchronously
                context.read<NotesBloc>().add(LoadNotes());
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(child: Text('No notes yet. Create one!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return _buildNoteCard(context, note);
              },
            );
          } else if (state is NotesError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/note-editor').then((_) {
            context.read<NotesBloc>().add(LoadNotes());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    Color noteColor = Colors.white;
    try {
      noteColor = Color(int.parse(note.color.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Card(
      color: noteColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          context.push('/note-editor', extra: note).then((_) {
            // ignore: use_build_context_synchronously
            context.read<NotesBloc>().add(LoadNotes());
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
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/note-editor', extra: note).then((_) {
                          // ignore: use_build_context_synchronously
                          context.read<NotesBloc>().add(LoadNotes());
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
                        child: Text('Edit Note'),
                      ),
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive Note'),
                      ),
                      const PopupMenuItem(
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
