import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConstPage extends StatefulWidget {
  const ConstPage();

  @override
  State<StatefulWidget> createState() {
    return _ConstState();
  }
}

class _ConstState extends State<ConstPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ConstPage'),
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
