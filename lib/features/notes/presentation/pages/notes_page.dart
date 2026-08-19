import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../../domain/entities/note.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/note_card_widget.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotesView();
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
              context.push(AppRoutes.search).then((_) {
                // ignore: use_build_context_synchronously
                if (context.mounted) context.read<NotesBloc>().add(LoadNotes());
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'archived') {
                context.push(AppRoutes.archived).then((_) {
                  // ignore: use_build_context_synchronously
                  if (context.mounted) context.read<NotesBloc>().add(LoadNotes());
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'archived',
                  child: Text('Archived Notes'),
                ),
              ];
            },
          ),
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const CardSkeletonList();
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(child: Text('No notes yet. Create one!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return NoteCardWidget(note: note, key: ValueKey(note.id));
              },
            );
          } else if (state is NotesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We encountered a database error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotesBloc>().add(LoadNotes());
                      },
                      child: const Text('Try Again'),
                    )
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.noteEditor).then((_) {
            // ignore: use_build_context_synchronously
            if (context.mounted) context.read<NotesBloc>().add(LoadNotes());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
