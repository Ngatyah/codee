import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

import 'home_page.dart';

onBackgroundMessage(SmsMessage message) async {
  return message;
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
