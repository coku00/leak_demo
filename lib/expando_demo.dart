import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_leaks/leaks_manager.dart';
import 'package:leak_demo/page1.dart';
import 'package:leak_demo/page2.dart';
import 'package:leak_detector/leak_detector.dart';
import 'closure_page.dart';
import 'const_page.dart';

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
    },
    title: 'Expand',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: 'page1',
  ));
}

const int _defaultCheckLeakDelay = 15;

class LeakObserver extends NavigatorObserver {
  final ShouldAddedRoute? shouldCheck;
  final int checkLeakDelay;

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
    route.didPush().then((value) {
      Element? element = _getElementByRoute(route);
      if (element != null) {
        print('_remove route hashCode ${route.hashCode}');
        Expando expando = Expando('${element.widget}');
        expando[element.widget] = true;
        _widgetRefMap[_generateKey(route)] = expando;
        if (element is StatefulElement) {
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
      Future.delayed(Duration(seconds: checkLeakDelay), () {
        LeaksTask(_widgetRefMap.remove(_generateKey(route)))
            .checkLeak(tag: "widget leaks");
        if (element is StatefulElement) {
          LeaksTask(_stateRefMap.remove(_generateKey(route)))
              .checkLeak(tag: "state leaks");
        }
      });
    }
  }

  String _generateKey(Route route) {
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
