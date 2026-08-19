import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_workspace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  title $textType,
  description $textType,
  isArchived $boolType,
  createdAt $textType,
  updatedAt $textType,
  color $textType,
  images $textNullableType,
  checklist $textNullableType
)
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
