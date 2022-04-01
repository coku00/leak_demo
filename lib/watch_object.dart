import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_leakcanary/flutter_leakcanary.dart';

class WatchObjectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WatchObjectState();
  }
}

_TestObject? _object;

class _WatchObjectState extends State<WatchObjectPage> {
  LeakWatcher? watcher;

  @override
  void initState() {
    super.initState();
    _object = _TestObject();
    watcher = LeakObject().leakObject(_object!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WatchObject'),
      ),
      body: Center(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.all(50),
              color: Colors.orange,
              child: Text('pop'),
            )),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
    watcher?.start();
  }
}

class _TestObject {}
