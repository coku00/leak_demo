import 'package:flutter/material.dart';

import 'expando_demo.dart';

class Page2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Page2State();
  }
}



class _Page2State extends State<Page2> {
  static List _value = [];
  @override
  void initState() {
    super.initState();
    _value.add(this);
    print('initState');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('page2'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {


            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.all(50),
            color: Colors.red,
            child: Text('pop'),
          )
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
