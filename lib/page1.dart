import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:leak_demo/const_page.dart';


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
      body: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomWidget('page2'),
            CustomWidget('closure'),
            CustomWidget('const'),
            CustomWidget('async'),
          ],
        ),
      )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomWidget extends StatelessWidget {
  final String routerName;

  CustomWidget(this.routerName);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      height: 40,
      width: 100,
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: GestureDetector(
        onTap: () {
          //
          if ('const' == routerName) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return  ConstPage();
            }));
          } else {
            Navigator.of(context).pushNamed(routerName);
          }
        },
        child: Container(
            color: Colors.yellow,
            height: 40,
            width: 100,
            child: Center(
              child: Text('go $routerName'),
            )),
      ),
    );
  }
}
