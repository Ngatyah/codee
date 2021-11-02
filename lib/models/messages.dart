import 'package:telephony/telephony.dart';
const String smsDb = 'messages';

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

