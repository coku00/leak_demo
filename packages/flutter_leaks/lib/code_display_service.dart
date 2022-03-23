import 'dart:developer';

import 'package:flutter_leaks/object_util.dart';
import 'package:flutter_leaks/service_util.dart';
import 'package:vm_service/vm_service.dart';
import 'dart:isolate' as sdk;

class CodeFindService {
  static CodeFindService get instance => _getInstance();

  static CodeFindService? _instance;

  CodeFindService._();

  static _getInstance() {
    if (_instance == null) {
      _instance = CodeFindService._();
    }
    return _instance;
  }

  Future<ClassList> getClassList({sdk.Isolate? sdkIsolate}) async {
    sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
    final _vmService = await getVmService();
    String isolateId = Service.getIsolateID(currentIsolate)!;
    return _vmService.getClassList(isolateId);
  }

  Future<ScriptList> getScriptList({sdk.Isolate? sdkIsolate}) async {
    sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
    final _vmService = await getVmService();
    String isolateId = Service.getIsolateID(currentIsolate)!;
    return _vmService.getScripts(isolateId);
  }

  Future<String> findIdByName(String className) async {
    String classId = '';
    final classList = await getClassList();
    classList.classes?.forEach((c) {
      if (c.name != null && c.name == className) {
        classId = c.id!;
        return;
      }
    });
    return classId;
  }

  Future<String?> findScriptIdByFileName(String fileName) async {
    ScriptList scriptList = await getScriptList();
    String? scriptId;
    scriptList.scripts?.forEach((script) {
      if (script.uri!.contains(fileName)) {
        scriptId = script.id;
        return;
      }
    });
    return scriptId;
  }

  Future<String?> findSourceByClassId(String classId) async {
    SourceLocation? location = await findLocationId(classId);
    if (location == null) {
      return null;
    }
    Script script = await getObjectOfType(location.script!.id!);
    return script.source;
  }

  Future<String?> findLocationUriById(String classId) async {
    SourceLocation? location = await findLocationId(classId);
    return location?.script?.uri;
  }

  Future<SourceLocation?> findLocationId(String classId) async {
    Class cls = await getObject(classId) as Class;
    return cls.location;
  }
}
