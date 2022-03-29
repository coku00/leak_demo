import 'package:flutter/cupertino.dart';

import 'leaks_manager.dart';

const int _defaultCheckLeakDelay = 15;

typedef ShouldAddedRoute = bool Function(Route route);

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


  void _add(Route route) {
    route.didPush().then((value) {
      Element? element = _getElementByRoute(route);
      if (element != null) {
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
      print("开始检测 ${element.widget}");
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