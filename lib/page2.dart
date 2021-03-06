import 'dart:async';

import 'package:flutter/material.dart';


final List _states = [];



final List _elements = [];

class SingleTon {

  final List _leakWidgets = [];
  static SingleTon _singleTon = SingleTon._();

  factory SingleTon() => _singleTon;

  SingleTon._();
}

class Page2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    SingleTon()._leakWidgets.add(this);
    return _Page2State();
  }
}

class _Page2State extends State<Page2> {
  @override
  void initState() {
    super.initState();
    _states.add(this);
  }

  void testFunc() {}

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
