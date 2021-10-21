import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

import 'file_utils.dart';

const mpesaFilter = r"^[A-Z]{2}[\dA-Z]{8}\sConfirmed"; 

class Homepage extends StatefulWidget {
  Function backgroundMessageHandler;
  Homepage(this.backgroundMessageHandler, {Key? key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<SmsMessage> messages = [];
  List<SmsMessage> allMessages = [];
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

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
    var allsms = await telephony.getInboxSms();
    RegExp exp = RegExp(mpesaFilter, multiLine: true);
    for (var sms in allsms) {
      bool matches = exp.hasMatch((sms.body).toString());
      if (matches) {
        setState(() {
          messages = [sms, ...messages];
        });
      }
      var data = json.encode(messages);
      FileUtils.saveToFile(data);
    }

    if (result != null && result) {
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
      body: messages.isEmpty
          ? const Center(child: Text('Loading...'))
          : ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.markunread),
                    title: Text((messages[index].address).toString()),
                    subtitle: Text(
                      (messages[index].body).toString(),
                      maxLines: 2,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.black),
              itemCount: messages.length),
    ));
  }
}
