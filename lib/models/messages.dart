const String smsDb = 'messages';
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const integerType = 'INTEGER NOT NULL';

class SmsFields {
  static final List<String> values = [
    id,
    title,
    body,
    date
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String body = 'body';
  static const String date = 'date';

}

