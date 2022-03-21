import 'package:flutter/material.dart';
import 'package:leak_demo/page2.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'expando_demo.dart';

class Page1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Page1State();
  }
}

class _Page1State extends State<Page1> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('page1'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return Page2();
            }));
          },
          child: VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {

            },
            key: ValueKey('page1'),
            child: Container(
              padding: EdgeInsets.all(50),
              color: Colors.blue,
              child: Text('go page2'),
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
