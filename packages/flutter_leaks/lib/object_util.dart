import 'dart:developer';
import 'dart:isolate' as sdk;

import 'package:flutter_leaks/service_util.dart';
import 'package:vm_service/vm_service.dart';

int _key = 0;

/// 顶级函数，必须常规方法，生成 key 用
String generateNewKey() {
  return "${++_key}";
}

Map<String, dynamic> _objCache = Map();

/// 顶级函数，根据 key 返回指定对象
dynamic key2Obj(String key) {
  return _objCache[key];
}

String _getIsolateId({sdk.Isolate? sdkIsolate}) {
  sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
  String isolateId = Service.getIsolateID(currentIsolate)!;
  return isolateId;
}

// dart对象转vm中的id
Future<String> obj2Id(dynamic obj, {sdk.Isolate? sdkIsolate}) async {
  String isolateId = _getIsolateId(sdkIsolate: sdkIsolate);
  VmService vmService = await getVmService();
  Isolate isolate = await vmService.getIsolate(isolateId);

  LibraryRef libraryRef = isolate.libraries!
      .where(
          (element) => element.uri == 'package:flutter_leaks/object_util.dart')
      .first;

  String libraryId = libraryRef.id!;

  // 用 vm service 执行 generateNewKey 函数生成 一个key
  Response keyRef =
      await vmService.invoke(isolateId, libraryId, "generateNewKey", []);
  //获取 generateNewKey 生成的key
  String key = keyRef.json!['valueAsString'];
  //把obj存到map
  _objCache[key] = obj;

  //key在vm中对应的id
  String vmId = keyRef.json!['id'];
  try {
    // 调用 key2Obj 顶级函数,获取obj的在vm中的信息 (ps:使用vmService调用有参数的函数不能直接传参数的值，需要传参数在VM中对应的id)
    Response objRef =
        await vmService.invoke(isolateId, libraryId, "key2Obj", [vmId]);
    // 获取obj在vm中的id
    // print('objRef =${objRef.json}');
    return objRef.json!['id'];
  } finally {
    //移除map中的值
    _objCache.remove(key);
  }
}

Future<AllocationProfile> gc({sdk.Isolate? sdkIsolate}) async {
  String isolateId = _getIsolateId(sdkIsolate: sdkIsolate);
  VmService vmService = await getVmService();
  return await vmService.getAllocationProfile(isolateId, gc: true);
}

Future<Obj?> getObject(String objectId, {sdk.Isolate? sdkIsolate}) async {
  sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
  String isolateId = Service.getIsolateID(currentIsolate)!;
  VmService vmService = await getVmService();
  Obj? obj = await vmService.getObject(isolateId, objectId);
  return obj;
}

Future<Type> getObjectOfType<Type extends Obj?>(String objectId,
    {sdk.Isolate? sdkIsolate}) async {
  var result = await getObject(objectId, sdkIsolate: sdkIsolate);
  return result as Type;
}

Future<List<InstanceRef>> getWeakKeyRefs(Expando expando) async {
  List<InstanceRef> instanceRefs = [];
  final weakPropertyRefs = await _getWeakProperty(expando);

  for (var i = 0; i < weakPropertyRefs.length; i++) {
    final weakPropertyRef = weakPropertyRefs[i];
    final weakPropertyId = weakPropertyRef.json?['id'];
    Obj? weakPropertyObj = await getObjectOfType(weakPropertyId);

    if (weakPropertyObj != null) {
      final weakPropertyInstance = Instance.parse(weakPropertyObj.json);
      if (weakPropertyInstance!.propertyKey != null) {
        instanceRefs.add(weakPropertyInstance.propertyKey!);
      }
    }
  }

  return instanceRefs;
}

Future<List<InstanceRef>> getWeakValueRefs(Expando expando) async {
  List<InstanceRef> instanceRefs = [];
  final weakPropertyRefs = await _getWeakProperty(expando);

  for (var i = 0; i < weakPropertyRefs.length; i++) {
    final weakPropertyRef = weakPropertyRefs[i];
    final weakPropertyId = weakPropertyRef.json?['id'];
    Obj? weakPropertyObj = await getObjectOfType(weakPropertyId);

    if (weakPropertyObj != null) {
      final weakPropertyInstance = Instance.parse(weakPropertyObj.json);
      if (weakPropertyInstance!.propertyKey != null) {
        instanceRefs.add(weakPropertyInstance.propertyValue!);
      }
    }
  }

  return instanceRefs;
}

Future<List<InstanceRef>> _getWeakProperty(Expando expando) async {
  String expandoId = await obj2Id(expando);
  Instance expandoObj = await getObjectOfType(expandoId);
  List<InstanceRef> instanceRefs = [];
  for (var i = 0; i < expandoObj.fields!.length; i++) {
    var filed = expandoObj.fields![i];
    if (filed.decl?.name == '_data') {
      String _dataId = filed.toJson()['value']['id'];
      Instance _data = await getObjectOfType(_dataId);
      if (_data is Instance) {
        for (int j = 0; j < _data.elements!.length; j++) {
          var weakProperty = _data.elements![j];
          if (weakProperty is InstanceRef) {
            InstanceRef weakPropertyRef = weakProperty;
            instanceRefs.add(weakPropertyRef);
          }
        }
      }
    }
  }

  return instanceRefs;
}

Future<RetainingPath> getRetainingPath(String objId,
    {sdk.Isolate? sdkIsolate, int? limit}) async {
  sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
  String isolateId = Service.getIsolateID(currentIsolate)!;
  VmService vmService = await getVmService();
  return vmService.getRetainingPath(isolateId, objId, limit ?? 300);
}
