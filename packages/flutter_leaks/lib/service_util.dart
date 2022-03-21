import 'dart:developer';

import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

VmService? _vmService;

Future<void> _initVmService() async {
  ServiceProtocolInfo serviceProtocolInfo = await Service.getInfo();
  print(serviceProtocolInfo.serverUri);
  Uri url =
      convertToWebSocketUrl(serviceProtocolUrl: serviceProtocolInfo.serverUri!);
  _vmService = await vmServiceConnectUri(url.toString());
}

Future<VmService> getVmService() async {
  if (_vmService == null) {
    await _initVmService();
  }
  return _vmService!;
}

Future<Stream<Event>> onGCEvent() async {
  VmService vmService = await getVmService();
  return vmService.onGCEvent;
}
