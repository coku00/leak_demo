
import 'package:flutter/widgets.dart';


class LeaksManager {
  static final LeaksManager _leaksManager = LeaksManager._();

  factory LeaksManager() => _leaksManager;

  LeaksManager._();

  Future<void> init() async {}

  void addWidget(Widget widget) {

  }

  void addElement(Element element) {

  }

  void addRoute(Route route) {

  }

  void addObject(Object object) {

  }

  void _addObject(Object object){

  }

}

class LeaksNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
  }
}
