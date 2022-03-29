import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AsyncPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AsyncState();
  }
}

class _AsyncState extends State<AsyncPage> {
  @override
  void initState() {
    super.initState();
    //模拟异步网络耗时
    Future.delayed(Duration(seconds: 100),(){
      _test();
    });
  }

  void _test(){
    print("_AsyncState");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AsyncPage'),
      ),
      body: Center(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.all(50),
              color: Colors.brown,
              child: Text('pop'),
            )),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

