import 'package:flutter/widgets.dart';
import 'package:vm_service/vm_service.dart';

import 'code_display_service.dart';
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
      print(
          'checkLeak weakPropertyKeys.isNotEmpty length = ${weakPropertyKeys.length}');
      leakNodes = [];
    }
    for (int i = 0; i < weakPropertyKeys.length; i++) {
      InstanceRef instanceRef = weakPropertyKeys[i];

      RetainingPath retainingPath = await getRetainingPath(instanceRef.id!);
      LeakNode? _leakInfoHead;
      LeakNode? pre;

      for (var i = 0; i < retainingPath.elements!.length; i++) {
        RetainingObject p = retainingPath.elements![i];
        LeakNode current = LeakNode();
        await _paresRef(p.value!, current);

        if (_leakInfoHead == null) {
          _leakInfoHead = current;
          pre = _leakInfoHead;
        } else {
          pre?.next = current;
          pre = current;
        }
      }

      if (_leakInfoHead != null) {
        leakNodes?.add(_leakInfoHead);
        print('发现内存泄露 : ${reverse(_leakInfoHead)}');
      }
    }

    return leakNodes;
  }
}

Future<void> _paresRef(ObjRef objRef, LeakNode leakNode) async {
  switch (objRef.runtimeType) {
    case ClassRef:
      ClassRef classRef = objRef as ClassRef;
      leakNode.id = classRef.id;
      leakNode.name = classRef.name;
      leakNode.isRoot = false;
      break;
    case CodeRef:
      CodeRef codeRef = objRef as CodeRef;
      leakNode.id = codeRef.id;
      leakNode.name = codeRef.name;
      leakNode.isRoot = false;
      break;
    case ContextRef:
      ContextRef contextRef = objRef as ContextRef;
      leakNode.id = contextRef.id;
      leakNode.name = 'context';
      leakNode.isRoot = false;
      break;
    case ErrorRef:
      ErrorRef errorRef = objRef as ErrorRef;
      leakNode.id = errorRef.id;
      leakNode.name = 'error';
      leakNode.isRoot = false;
      break;
    case FieldRef:
      FieldRef fieldRef = objRef as FieldRef;
      leakNode.id = fieldRef.id;
      leakNode.name = fieldRef.name;
      leakNode.isRoot = fieldRef.isStatic ?? false;

      Field field = await getObjectOfType(objRef.id!);
      leakNode.codeInfo = await _getFieldCode(field);

      break;
    case FuncRef:
      FuncRef funcRef = objRef as FuncRef;
      leakNode.id = funcRef.id;
      leakNode.name = funcRef.name;
      leakNode.isRoot = false;
      break;
    case InstanceRef:
      InstanceRef instanceRef = objRef as InstanceRef;
      leakNode.id = instanceRef.id;
      leakNode.name = instanceRef.name ?? instanceRef.classRef?.name;
      leakNode.isRoot = false;
      break;
    case ScriptRef:
      ScriptRef scriptRef = objRef as ScriptRef;
      leakNode.id = scriptRef.id;
      leakNode.name = "script";
      leakNode.isRoot = false;
      break;
    case TypeArgumentsRef:
      TypeArgumentsRef typeArgumentsRef = objRef as TypeArgumentsRef;
      leakNode.id = typeArgumentsRef.id;
      leakNode.name = typeArgumentsRef.name;
      leakNode.isRoot = false;
      break;
    default:
      break;
  }
}

Future<void> _findSource(Obj obj) async {
  SourceLocation? location;

  switch (obj.runtimeType) {
    case Breakpoint:
      Breakpoint breakpoint = obj as Breakpoint;
      location = breakpoint.location;
      break;
    case Class:
      Class clazz = obj as Class;
      location = clazz.location;
      String? code =
          await CodeFindService.instance.findSourceByClassId(clazz.id!);

      break;
    case Code:
      Code code = obj as Code;

      break;
    case Context:
      Context context = obj as Context;
      break;
    case Error:
      Error error = obj as Error;
      break;
    case Field:
      Field field = obj as Field;
      location = field.location;
      break;
    case Func:
      Func func = obj as Func;
      break;
    case Instance:
      Instance instance = obj as Instance;

      break;
    case Library:
      Library library = obj as Library;

      break;
    case Script:
      Script script = obj as Script;

      break;
    case TypeArguments:
      TypeArguments typeArguments = obj as TypeArguments;

      break;
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

  CodeInfo? codeInfo;

  @override
  String toString() {
    return '[name : $name; id : $id; isRoot :$isRoot; ${codeInfo == null ? '' : 'codeInfo : ${codeInfo?.toString()}'}] ${next == null ? '' : '---> ${next?.toString()}'}';
  }
}

Future<CodeInfo?> getCodeInfo(SourceLocation location) async {
  if (location.script != null && location.tokenPos != null) {
    Script script = await getObjectOfType(location.script!.id!);
    int? line = script.getLineNumberFromTokenPos(location.tokenPos!);
    int? column = script.getColumnNumberFromTokenPos(location.tokenPos!);
    String? codeLine;
    codeLine = script.source
        ?.substring(location.tokenPos!, location.endTokenPos)
        .split('\n')
        .first;
    CodeInfo codeInfo = CodeInfo(line, column, codeLine);
    print(codeInfo);
    return codeInfo;
  }
  return null;
}

Future<CodeInfo?> _getFieldCode(Field field) async {
  if (field.location?.script?.id != null) {
    Script? script = await getObjectOfType(field.location!.script!.id!);

    if (script != null && field.location?.tokenPos != null) {
      int? line = script.getLineNumberFromTokenPos(field.location!.tokenPos!);
      int? column =
          script.getColumnNumberFromTokenPos(field.location!.tokenPos!);
      String? codeLine;
      codeLine = script.source
          ?.substring(field.location!.tokenPos!, field.location!.endTokenPos)
          .split('\n')
          .first;

      CodeInfo codeInfo = CodeInfo(line, column, codeLine);
      print(codeInfo);
      return codeInfo;
    }
  }
  return null;
}

class CodeInfo {
  int? line;
  int? column;
  String? codeLine;

  CodeInfo(this.line, this.column, this.codeLine);

  @override
  String toString() {
    return 'line :$line; column :$column; codeLine :$codeLine';
  }
}
