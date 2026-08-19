import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<List<Note>> searchNotes(String query);
  Future<Note> getNoteById(String id);
  Future<void> insertNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> archiveNote(String id);
}
