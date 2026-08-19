import 'package:employee_manage/features/notes/domain/entities/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/note_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository repository;

  NotesBloc({required this.repository}) : super(NotesInitial()) {
    on<LoadNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        final notes = await repository.getNotes();
        emit(NotesLoaded(notes));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<SearchNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        final notes = await repository.searchNotes(event.query);
        emit(NotesLoaded(notes));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<AddNote>((event, emit) async {
      try {
        await repository.insertNote(event.note);
        add(LoadNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<UpdateNote>((event, emit) async {
      try {
        await repository.updateNote(event.note);
        add(LoadNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<DeleteNote>((event, emit) async {
      try {
        await repository.deleteNote(event.id);
        add(LoadNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<ArchiveNote>((event, emit) async {
      try {
        await repository.archiveNote(event.id);
        add(LoadNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<GenerateMockData>((event, emit) async {
      emit(NotesLoading());
      try {
        final now = DateTime.now();
        for (int i = 0; i < 5000; i++) {
          final note = Note(
            id: 'mock_note_$i',
            title: 'Mock Note Title $i',
            description:
                'This is a mock note description for note number $i. It contains some keywords for search testing.',
            isArchived: false,
            createdAt: now,
            updatedAt: now,
            color: '#FFFFFF',
            images: const [],
            checklist: const [],
          );
          await repository.insertNote(note);
        }
        add(LoadNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });
  }
}
