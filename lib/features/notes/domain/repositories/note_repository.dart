import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<List<Note>> getArchivedNotes();
  Future<List<Note>> searchNotes(String query);
  Future<Note> getNoteById(String id);
  Future<void> insertNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> archiveNote(String id);
  Future<void> insertNotes(List<Note> notes);
  Future<List<Map<String, dynamic>>> getSyncQueue();
  Future<void> clearSyncQueue();
  Future<void> addToSyncQueue(String noteId, String operation);
}
