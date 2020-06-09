import 'package:flutter/material.dart';
import '../util/database.dart';

class Progress extends StatefulWidget {
  const Progress({Key key}) : super(key: key);

  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: resultStream??null,
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return Container();
        }
        return Text((snapshot.data/686*100).toStringAsFixed(0) + ' %');
      },
    );
  }
}
