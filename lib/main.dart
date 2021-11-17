import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'database/sms_database.dart';
import 'home_page.dart';
import 'models/messages.dart';

onBackgroundMessage(SmsMessage message) async {
  print("Backgroud Message called");
  RegExp exp = RegExp(mpesaFilter, multiLine: true);
  bool matches = exp.hasMatch((message.body).toString());
  if (matches) {
    await SmsDatabase.instance.insert({
      SmsFields.id: message.id,
      SmsFields.body: message.body,
      SmsFields.title: message.address,
      SmsFields.date: message.date,
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Homepage(onBackgroundMessage),
    );
  }
}
