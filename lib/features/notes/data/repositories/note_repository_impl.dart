import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final DatabaseHelper databaseHelper;

  NoteRepositoryImpl({required this.databaseHelper});

  @override
  Future<List<Note>> getNotes() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'isArchived = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }

  @override
  Future<Note> getNoteById(String id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return NoteModel.fromJson(maps.first);
    } else {
      throw Exception('Note not found');
    }
  }

  @override
  Future<void> insertNote(Note note) async {
    final db = await databaseHelper.database;
    await db.insert(
      'notes',
      NoteModel.fromEntity(note).toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateNote(Note note) async {
    final db = await databaseHelper.database;
    await db.update(
      'notes',
      NoteModel.fromEntity(note).toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    final db = await databaseHelper.database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> archiveNote(String id) async {
    final db = await databaseHelper.database;
    await db.update(
      'notes',
      {'isArchived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> insertNotes(List<Note> notes) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    for (var note in notes) {
      batch.insert('notes', NoteModel.fromEntity(note).toJson());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await databaseHelper.database;
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  @override
  Future<void> clearSyncQueue() async {
    final db = await databaseHelper.database;
    await db.delete('sync_queue');
  }

  @override
  Future<void> addToSyncQueue(String noteId, String operation) async {
    final db = await databaseHelper.database;
    await db.insert('sync_queue', {
      'noteId': noteId,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
