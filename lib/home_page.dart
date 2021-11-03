import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:telephony/telephony.dart';
import 'database/sms_database.dart';
import 'file_utils.dart';
import 'models/messages.dart';

const mpesaFilter = r"^[A-Z]{2}[\dA-Z]{8}\sConfirmed";

class Homepage extends StatefulWidget {
  Function backgroundMessageHandler;
  Homepage(this.backgroundMessageHandler, {Key? key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<SmsMessage> messages = [];
  List txtSms = [];
  List<Map<String, dynamic>> querrySms = [];
  final telephony = Telephony.instance;
  int? count = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  //convert to json
  // List<dynamic> toJson(smses) {
  //   for (var sms in smses) {
  //     var tinga = {
  //       'id': sms.address,
  //       'body': sms.body,
  //       'address': sms.id,
  //       'date': sms.date,
  //     };
  //     txtSms.add(tinga);
  //   }

  //   return txtSms;
  // }

  onMessage(SmsMessage message) async {
    setState(() {
      RegExp exp = RegExp(mpesaFilter, multiLine: true);
      bool matches = exp.hasMatch((message.body).toString());
      if (matches) {
        messages = [message, ...messages];
      }
    });
  }

  backgroundMessage(dynamic sms) async {
    var backgroundSms = widget.backgroundMessageHandler();
    setState(() {
      RegExp exp = RegExp(mpesaFilter, multiLine: true);
      bool matches = exp.hasMatch((backgroundSms.body).toString());
      if (matches) {
        messages = [backgroundSms, ...messages];
      }
    });
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    count = Sqflite.firstIntValue(await SmsDatabase.instance.readAll());
    

    print('Helps to check if there is vallue $count');

    if (result != null && result) {
      var allsms = await telephony.getInboxSms(columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.ID,
        SmsColumn.DATE
      ]);
      RegExp exp = RegExp(mpesaFilter, multiLine: true);
      for (var sms in allsms) {
        bool matches = exp.hasMatch((sms.body).toString());
        if (matches && count==null) {
          await SmsDatabase.instance.insert({
            SmsFields.id: sms.id,
            SmsFields.body: sms.body,
            SmsFields.title: sms.address,
            SmsFields.date: sms.date,
          });
          // print(count);
         
        }
         
          setState(() {
            messages = [sms, ...messages];
            querrySms.length;
          });
      }
      querrySms = await SmsDatabase.instance.readAll();

      // var user = toJson(messages);
      // final jsonString = json.encode(user);
      // FileUtils.saveToFile(jsonString);
      // FileUtils.readFiles().then((data) {
      //   setState(() {
      //     print('Here is the Data $data');
      //   });
      // });

      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: backgroundMessage);
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: querrySms.isEmpty
          ? const Center(child: Text('Loading...'))
          : ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.markunread),
                    title: Text((querrySms[index]['title']).toString()),
                    subtitle: Text(
                      (querrySms[index]['body']).toString(),
                      maxLines: 2,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.cyan),
              itemCount: querrySms.length),
    ));
  }
}
