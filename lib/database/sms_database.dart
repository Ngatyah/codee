import 'package:codee/models/messages.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class SmsDatabase {
static final SmsDatabase instance = SmsDatabase._init();
static Database? _database;
  SmsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('messages.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    final _dbPath = await getDatabasesPath();
    final path = join(_dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $smsDb(
      ${SmsFields.id} $idType,
      ${SmsFields.body} $textType,
      ${SmsFields.title} $textType,
      ${SmsFields.date} $textType 
    )
    ''');
  }


}
