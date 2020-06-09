import 'package:flutter/material.dart';

import '../util/custom_icons_icons.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Developer:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            Image.asset('assets/santosh.jpg',fit: BoxFit.cover),
            Divider(),
             Text(
              'Santosh Thapa',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            Divider(),
            Text(
              'Contact:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      CustomIcons.facebook,
                      color: Colors.blue,
                    ),
                    onPressed: () {}),
                IconButton(
                    icon: Icon(
                      CustomIcons.instagram,
                      color: Colors.blue,
                    ),
                    onPressed: () {}),
                IconButton(
                    icon: Icon(
                      CustomIcons.twitter,
                      color: Colors.blue,
                    ),
                    onPressed: () {}),
              ],
            ),
            Divider(),
            Text(
              'Special Thanks:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(
              'Mani Kashyap \n\nAmrit Giri \n\nAshish Pathak \n\nSandip Khanal \n\nYubraj Shrestha \n\nAbhisek Joshi \n\nSantosh Aryal \n\nKrishna Gyawali\n\n',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
