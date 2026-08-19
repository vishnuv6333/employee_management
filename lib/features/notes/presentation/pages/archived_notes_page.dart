import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../widgets/archived_note_card_widget.dart';

class ArchivedNotesPage extends StatefulWidget {
  const ArchivedNotesPage({super.key});

  @override
  State<ArchivedNotesPage> createState() => _ArchivedNotesPageState();
}

class _ArchivedNotesPageState extends State<ArchivedNotesPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadArchivedNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived Notes')),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const CardSkeletonList();
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(child: Text('No archived notes.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return ArchivedNoteCardWidget(
                  note: note,
                  key: ValueKey(note.id),
                );
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
                        context.read<NotesBloc>().add(LoadArchivedNotes());
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
    );
  }
}
