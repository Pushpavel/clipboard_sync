import 'dart:io';

import 'package:clipboard_sync/logic/models/info.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<DeviceInfo?> getDeviceInfo() async {
  final p = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final info = await p.androidInfo;
    if (info.androidId == null) return null;
    return DeviceInfo(
        info.androidId!, info.host ?? info.model ?? info.product ?? info.hardware ?? info.board ?? "Android Phone");
  }

  if (Platform.isLinux) {
    final info = await p.linuxInfo;
    if (info.machineId == null) return null;
    return DeviceInfo(info.machineId!, info.prettyName);
  }

  if (Platform.isWindows) {
    final info = await p.windowsInfo;
    return DeviceInfo(
            info.computerName +
            info.systemMemoryInMegabytes.toString() +
            info.numberOfCores.toString(),
        info.computerName);
  }

  return null;
}
