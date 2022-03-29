



import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final List<TestFunction?> _functions = [];

typedef TestFunction = int Function();

class ClosurePage extends StatefulWidget {
  const ClosurePage();
  @override
  State<StatefulWidget> createState() {
    return _ClosureState();
  }
}
class _ClosureState extends State<ClosurePage> {

  @override
  void initState() {
    super.initState();
    _functions.add(() {
  //    testFunc();
      return 1;
    });
  }

  void testFunc() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('ClosurePage'),
      ),
      body: Center(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.all(50),
              color: Colors.lightGreen,
              child: Text('pop'),
            )),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}