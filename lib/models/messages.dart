const String smsDb = 'messages';
const idType = 'INTEGER PRIMARY KEY';
const textType = 'TEXT NOT NULL';
const integerType = 'INTEGER NOT NULL';
const orderBy = '${SmsFields.date} ASC';

class SmsFields {
  static final List<String> values = [
    id,
    title,
    body,
    date
  ];

  static const String id = 'id';
  static const String title = 'title';
  static const String body = 'body';
  static const String date = 'date';

}

