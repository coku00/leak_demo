import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:leak_demo/page1.dart';
import 'package:leak_detector/leak_detector.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Expando expando = Expando();

main() {
  LeakDetector().init();
  LeakDetector().onLeakedStream.listen((LeakedInfo info) {
    print(info);
    //print to console
    info.retainingPath.forEach((node) => print(node));
    //show preview page
    showLeakedInfoPage(navigatorKey.currentContext!, info);
  });
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: [LeakNavigatorObserver()],
    title: 'Expand',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Page1(),
  ));
}
