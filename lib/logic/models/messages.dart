import 'dart:io';

import 'package:clipboard_sync/logic/models/Info.dart';

class ClipboardMessage {
  final String originId;
  final String originName;
  final String value;

  ClipboardMessage(this.originId, this.originName, this.value);
}

class ServerInfoMessage {
  final DeviceInfo deviceInfo;
  final ServerSocket serverSocket;

  ServerInfoMessage(this.deviceInfo, this.serverSocket);
}
