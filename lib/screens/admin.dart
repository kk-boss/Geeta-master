import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FirebaseTest extends StatefulWidget {
  @override
  _FirebaseTestState createState() => _FirebaseTestState();
}

class _FirebaseTestState extends State<FirebaseTest> {


  final String serverToken =
      'AAAAi5HvwgM:APA91bGKBq7guD4D-mdb5cx50-3EUwos8hCZYlr6fz_n2NfcJRTCNmoozicVDIc6F2Jxxm5_zYWhf2WvaBgdilLDbyB7X51ZDEEbBO6gmNUdiVfFE2w5lHmvCP8c79VYZFrcQWoPtpm5';

  Future<void> sendAndRetrieveMessage(List<String> msg) async {
   await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': msg[1], 'title': msg[0]},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': '/topics/all'
        },
      ),
    );


  }

  TextEditingController _ctr1 = TextEditingController();
  TextEditingController _ctr2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Notification')),
      body: Container(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ctr1,
              decoration: InputDecoration(labelText: 'Enter Title'),
            ),
            TextField(
              controller: _ctr2,
              decoration: InputDecoration(labelText: 'Enter Body'),
            ),
            RaisedButton(
              onPressed: () async {
                await sendAndRetrieveMessage([_ctr1.text, _ctr2.text]);
              },
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
