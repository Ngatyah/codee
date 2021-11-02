import 'package:telephony/telephony.dart';
import 'package:codee/models/messages.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    Directory _dbPath = await getApplicationDocumentsDirectory();
    final path = join(_dbPath.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $smsDb(
      ${SmsFields.id} $idType,
      ${SmsFields.body} $textType,
      ${SmsFields.title} $textType,
      ${SmsFields.date} $integerType 
    )
    ''');
  }

  Future<int> insert(Map<String, dynamic> sms) async {
    Database db = await instance.database;
    return await db.insert(smsDb, sms);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final orderBy = '${SmsFields.date} ASC';
    Database db = await instance.database;
    return await db.query(smsDb,orderBy: orderBy);
  }
}
