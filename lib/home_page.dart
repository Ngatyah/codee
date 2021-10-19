import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

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
    messages.add(message);
  }

  backgroundMessage(dynamic sms) async {
    var backgroundSms = widget.backgroundMessageHandler();
    messages.add(backgroundSms);
  }

  Future<void> allMessage() async {
    allMessages = await telephony.getInboxSms();
    for (var message in allMessages) {
      messages.add(message);
    }
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

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
            body: FutureBuilder(
              future: allMessage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none) {
                  return const Center(
                    child: Text('Loading ...'),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        messages;
                      });
                    },
                    child: ListView.separated(
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
                  );
                }
              },
            )));
  }
}
