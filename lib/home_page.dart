import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'database/sms_database.dart';
import 'models/messages.dart';

const mpesaFilter = r"^[A-Z]{2}[\dA-Z]{8}\sConfirmed";

class Homepage extends StatefulWidget {
  Function backgroundMessageHandler;
  Homepage(this.backgroundMessageHandler, {Key? key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  List<SmsMessage> messages = [];
  // List txtSms = [];
  bool isLoading = false;
  List<Map<String, dynamic>> querrySms = [];
  final telephony = Telephony.instance;
  int messageCount = 0;
  int? dbCount = 0;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("Did the cycle change");
    setState(() {
      refreshSmses();
    });
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

  updateDb() {
    for (var sms in messages) {
      var messageId = sms.id;
      print('This is the Message Id: $messageId');
    }
  }

  Future<void> initPlatformState() async {
    var txtMessages = [];
    RegExp exp = RegExp(mpesaFilter, multiLine: true);
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    var allsms = await telephony.getInboxSms();
    for (var text in allsms) {
      bool matches = exp.hasMatch((text.body).toString());
      if (matches) {
        txtMessages = [text, ...txtMessages];
      }
    }

    querrySms = await SmsDatabase.instance.readAll();
    messageCount = txtMessages.length;
    print('Here we get Mpesa Messages Count $messageCount');
    dbCount = await SmsDatabase.instance.getProfilesCount();

    print('Count sms in DB $dbCount');

    if (result != null && result) {
      var allsms = await telephony.getInboxSms(columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.ID,
        SmsColumn.DATE
      ]);

      if (dbCount == 0 || messageCount!=dbCount) {
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
      updateDb();
      // var user = toJson(messages);
      // final jsonString = json.encode(user);
      // FileUtils.saveToFile(jsonString);
      // FileUtils.readFiles().then((data) {
      //   setState(() {
      //     print('Here is the Data $data');
      //   });
      // });

      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: widget.backgroundMessageHandler as dynamic);
    }
    if (!mounted) return;
  }

  Future refreshSmses() async {
    print("Refresher called");
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
