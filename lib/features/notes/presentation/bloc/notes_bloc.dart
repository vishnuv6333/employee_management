import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:employee_manage/features/notes/domain/entities/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/note_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/sync_service.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository repository;
  final SharedPreferences sharedPreferences;
  final SyncService syncService;
  List<Note>? _cachedMockNotes;
  bool _isShowingArchived = false;

  NotesBloc({
    required this.repository, 
    required this.sharedPreferences,
    required this.syncService,
  }) : super(NotesInitial()) {
    on<LoadNotes>((event, emit) async {
      _isShowingArchived = false;
      emit(NotesLoading());
      try {
        final notes = await repository.getNotes();
        emit(NotesLoaded(notes));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<LoadArchivedNotes>((event, emit) async {
      _isShowingArchived = true;
      emit(NotesLoading());
      try {
        final notes = await repository.getArchivedNotes();
        emit(NotesLoaded(notes));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<SearchNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        // Search local database
        final dbNotes = await repository.searchNotes(event.query);
        
        // Search mock dataset (only for search)
        if (_cachedMockNotes == null) {
          final String jsonString = await rootBundle.loadString('assets/mock_notes.json');
          final List<dynamic> jsonList = json.decode(jsonString);
          _cachedMockNotes = jsonList.map((jsonItem) {
            return Note(
              id: jsonItem['id'],
              title: jsonItem['title'],
              description: jsonItem['description'],
              isArchived: jsonItem['isArchived'] == 1,
              createdAt: DateTime.parse(jsonItem['createdAt']),
              updatedAt: DateTime.parse(jsonItem['updatedAt']),
              color: jsonItem['color'],
              images: const [],
              checklist: const [],
            );
          }).toList();
        }

        final query = event.query.toLowerCase();
        final mockResults = _cachedMockNotes!.where((note) {
          return note.title.toLowerCase().contains(query) || 
                 note.description.toLowerCase().contains(query);
        }).toList();

        emit(NotesLoaded([...dbNotes, ...mockResults]));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<AddNote>((event, emit) async {
      try {
        await repository.insertNote(event.note);
        if (syncService.isOffline) {
          await repository.addToSyncQueue(event.note.id, 'ADD');
        }
        if (_isShowingArchived) {
          add(LoadArchivedNotes());
        } else {
          add(LoadNotes());
        }
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<UpdateNote>((event, emit) async {
      try {
        await repository.updateNote(event.note);
        if (syncService.isOffline) {
          await repository.addToSyncQueue(event.note.id, 'UPDATE');
        }
        if (_isShowingArchived) {
          add(LoadArchivedNotes());
        } else {
          add(LoadNotes());
        }
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<DeleteNote>((event, emit) async {
      try {
        await repository.deleteNote(event.id);
        if (syncService.isOffline) {
          await repository.addToSyncQueue(event.id, 'DELETE');
        }
        if (_isShowingArchived) {
          add(LoadArchivedNotes());
        } else {
          add(LoadNotes());
        }
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<ArchiveNote>((event, emit) async {
      try {
        await repository.archiveNote(event.id);
        if (syncService.isOffline) {
          await repository.addToSyncQueue(event.id, 'UPDATE');
        }
        if (_isShowingArchived) {
          add(LoadArchivedNotes());
        } else {
          add(LoadNotes());
        }
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<GenerateMockData>((event, emit) async {
      emit(NotesLoading());
      try {
        final String jsonString = await rootBundle.loadString(
          'assets/mock_notes.json',
        );
        final List<dynamic> jsonList = json.decode(jsonString);

        final List<Note> notes = jsonList.map((jsonItem) {
          return Note(
            id: jsonItem['id'],
            title: jsonItem['title'],
            description: jsonItem['description'],
            isArchived: jsonItem['isArchived'] == 1,
            createdAt: DateTime.parse(jsonItem['createdAt']),
            updatedAt: DateTime.parse(jsonItem['updatedAt']),
            color: jsonItem['color'],
            images: const [],
            checklist: const [],
          );
        }).toList();

        await repository.insertNotes(notes);
        add(LoadNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });
  }
}
