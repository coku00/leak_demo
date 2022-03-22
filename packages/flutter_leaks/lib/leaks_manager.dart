import 'package:flutter/widgets.dart';
import 'package:vm_service/vm_service.dart';

import 'object_util.dart';

class LeaksManager {
  static final LeaksManager _leaksManager = LeaksManager._();

  factory LeaksManager() => _leaksManager;

  LeaksManager._();

  Future<void> init() async {}

  void addWidget(Widget widget) {}

  void addElement(Element element) {}

  void addRoute(Route route) {}

  void addObject(Object object) {}

  void _addObject(Object object) {}

  void checkLeak() {}
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

class LeaksTask {
  Expando? expando;

  LeaksTask(this.expando);

  Future<List<LeakNode>?> checkLeak() async {
    List<LeakNode>? leakNodes;
    if (expando == null) {
      print('checkLeak expando = null');
      return leakNodes;
    }
    await gc();

    final weakPropertyKeys = await getWeakKeyRefs(expando!);
    expando = null;
    if (weakPropertyKeys.isNotEmpty) {
      print('checkLeak weakPropertyKeys.isNotEmpty length = ${weakPropertyKeys.length}');
      leakNodes = [];
    }
    for (int i = 0; i < weakPropertyKeys.length; i++) {
      InstanceRef instanceRef = weakPropertyKeys[i];

      RetainingPath retainingPath = await getRetainingPath(instanceRef.id!);
      LeakNode? _leakInfoHead;
      LeakNode? pre;

      retainingPath.elements?.forEach((p) {
        LeakNode current = LeakNode();

        if (p.value is InstanceRef) {
          InstanceRef instanceRef = p.value as InstanceRef;
         // print('内存泄漏链路 ---->  ${instanceRef.classRef?.name}');
          current.name = instanceRef.classRef?.name;
          current.id = instanceRef.classRef?.id;
          current.isRoot = false;
        } else if (p.value is FieldRef) {
          FieldRef fieldRef = p.value as FieldRef;
          current.name = fieldRef.name;
          current.id = fieldRef.id;
          current.isRoot = true;
         // print('内存泄漏链路 ---->  ${fieldRef.name}');
        }

        if (_leakInfoHead == null) {
          _leakInfoHead = current;
          pre = _leakInfoHead!;
        } else {
          pre?.next = current;
          pre = current;
        }
      });

      if(_leakInfoHead != null){
        leakNodes?.add(_leakInfoHead!);
        print('发现内存泄露 : ${reverse(_leakInfoHead!)}');
      }

    }

    return leakNodes;
  }
}

LeakNode? reverse(LeakNode? head) {
  LeakNode? prev;
  LeakNode? current = head;

  // 1 , 2 , 3 , 4
  while (current != null) {
    LeakNode? pNext;
    pNext = current.next; //2
    //反转下一个节点指向
    current.next = prev; // null
    //移动前一个节点的指针
    prev = current; // 1
    //移动当前的指针
    current = pNext; // 2
  }
  return prev!;
}

class LeakNode {
  bool isRoot = false;

  LeakNode? next;

  String? id;

  String? name;

  String? type;

  @override
  String toString() {
    return '[name : $name; id : $id; isRoot :$isRoot] ${next == null ? '' : '---> ${next?.toString()}'}';
  }
}
