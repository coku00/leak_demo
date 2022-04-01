import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:leak_demo/page1.dart';
import 'package:leak_demo/page2.dart';
import 'package:leak_demo/watch_object.dart';

import 'async_page.dart';
import 'closure_page.dart';
import 'const_page.dart';
import 'package:flutter_leakcanary/flutter_leakcanary.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

main() {
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: [LeakObserver()],
    routes: <String, WidgetBuilder>{
      "page1": (BuildContext context) {
        return Page1();
      },
      "page2": (BuildContext context) {
        return Page2();
      },
      "closure": (BuildContext context) {
        return ClosurePage();
      },
      "const": (BuildContext context) {
        return const ConstPage();
      },
      "async": (BuildContext context) {
        return  AsyncPage();
      },
      'WatchObject':(_){
        return WatchObjectPage();
      }
    },
    title: 'Expand',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: 'page1',
  ));
}


