import 'dart:convert';
import 'dart:io';

import 'package:clipboard_sync/logic/models/info.dart';

class Advertiser {
  RawDatagramSocket? _socket;

  start(DeviceInfo info) async {
    if (_socket != null) return;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 38899);

      _socket!.readEventsEnabled = true;
      _socket!.writeEventsEnabled = true;
      _socket!.broadcastEnabled = true;

      final json = {
        "id": info.id,
        "name": info.name,
      };

      final jsonBytes = utf8.encode(jsonEncode(json));

      while (true) {
        _socket!.send(jsonBytes, InternetAddress("255.255.255.255"), 38899);
        Future.delayed(Duration(seconds: 1));
      }
    } finally {
      _socket?.close();
      _socket = null;
    }
  }

  isAdvertising() => _socket != null;

  stop() => _socket?.close();
}
