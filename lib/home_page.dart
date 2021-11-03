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
  // List txtSms = [];
  bool isLoading = false;
  List<Map<String, dynamic>> querrySms = [];
  final telephony = Telephony.instance;
  int? count = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    refreshSmses();
  }
  @override
  void dispose() {
    super.dispose();
     SmsDatabase.instance.close();
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
  addSmsToDatabase(dynamic message) async {
    await SmsDatabase.instance.insert({
      SmsFields.id: message.id,
      SmsFields.body: message.body,
      SmsFields.title: message.address,
      SmsFields.date: message.date,
    });
  }

  onMessage(SmsMessage message) async {
    RegExp exp = RegExp(mpesaFilter, multiLine: true);
    bool matches = exp.hasMatch((message.body).toString());
    if (matches) {
      addSmsToDatabase(message);
      setState(() async {
        messages = [message, ...messages];
      });
    }
  }

  backgroundMessage(dynamic sms) async {
    var bgSms = widget.backgroundMessageHandler();

    RegExp exp = RegExp(mpesaFilter, multiLine: true);
    bool matches = exp.hasMatch((bgSms.body).toString());
    if (matches) {
      refreshSmses();
      addSmsToDatabase(bgSms);
      setState(() async {
        messages = [bgSms, ...messages];
      });
    }
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
      if (count == null) {
        for (var sms in allsms) {
          querrySms = await SmsDatabase.instance.readAll();
          bool matches = exp.hasMatch((sms.body).toString());
          if (matches) {
            addSmsToDatabase(sms);
            setState(() {
              messages = [sms, ...messages];
              querrySms.length;
            });
          }
        }
      }

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

  Future refreshSmses() async {
    setState(() => isLoading = true);
    querrySms = await SmsDatabase.instance.readAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
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
