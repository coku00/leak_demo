import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_leaks/leaks_manager.dart';
import 'package:leak_demo/page1.dart';
import 'package:leak_detector/leak_detector.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

main() {
  // LeakDetector().init();
  // LeakDetector().onLeakedStream.listen((LeakedInfo info) {
  //   print(info);
  //   //print to console
  //   info.retainingPath.forEach((node) => print(node));
  //   //show preview page
  //   showLeakedInfoPage(navigatorKey.currentContext!, info);
  // });
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: [LeakObserver()],
    title: 'Expand',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Page1(),
  ));
}

const int _defaultCheckLeakDelay = 500;

class LeakObserver extends NavigatorObserver {
  final ShouldAddedRoute? shouldCheck;
  final int checkLeakDelay;

  ///[callback] if 'null',the all route can added to LeakDetector.
  ///if not 'null', returns ‘true’, then this route will be added to the LeakDetector.
  LeakObserver(
      {this.checkLeakDelay = _defaultCheckLeakDelay, this.shouldCheck});

  @override
  void didPop(Route route, Route? previousRoute) {
    _remove(route);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _add(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _add(newRoute);
    }
    if (oldRoute != null) {
      _remove(oldRoute);
    }
  }

  Map<String, Expando> _widgetRefMap = {};
  Map<String, Expando> _stateRefMap = {};

  ///add a object to LeakDetector
  void _add(Route route) {
    route.didPush().then((value){
      Element? element = _getElementByRoute(route);
      if (element != null) {
        print('_remove route hashCode ${route.hashCode}');
        Expando expando = Expando('${element.widget}');
        expando[element.widget] = true;
        _widgetRefMap[_generateKey(route)] = expando;
        if(element is StatefulElement){
          Expando expandoState = Expando('${element.state}');
          expando[element.state] = true;
          _stateRefMap[_generateKey(route)] = expandoState;
        }
      }
    });

  }

  ///check and analyze the route
  void _remove(Route route) {
    Element? element = _getElementByRoute(route);
    if (element != null) {
        Future.delayed(Duration(seconds: 1), () async {
           LeaksTask(_widgetRefMap.remove(_generateKey(route))).checkLeak();
           if(element is StatefulElement){
             LeaksTask(_stateRefMap.remove(_generateKey(route))).checkLeak();
           }
        });
    }
  }

  String _generateKey(Route route){
    return '${route.hashCode}-${route.runtimeType}';
  }

  ///Get the ‘Element’ of our custom page
  Element? _getElementByRoute(Route route) {
    Element? element;
    if (route is ModalRoute &&
        (shouldCheck == null || shouldCheck!.call(route))) {
      //RepaintBoundary
      route.subtreeContext?.visitChildElements((child) {
        //Builder
        child.visitChildElements((child) {
          //Semantics
          child.visitChildElements((child) {
            //My Page
            element = child;
          });
        });
      });
    }
    return element;
  }
}
