import 'package:flutter/material.dart';

import 'expando_demo.dart';

class Page2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _widgets.add(this);
    return _Page2State();
  }
}

final List _states = [];
final List _widgets = [];

class _Page2State extends State<Page2> {
  @override
  void initState() {
    super.initState();
    // _states.add(this);
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
            )),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
