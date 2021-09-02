import 'dart:convert';

import 'dart:io';

import 'package:clipboard_sync/logic/models/messages.dart';

class ServerInfoMessage {
  final int port;
  final InternetAddress address;

  ServerInfoMessage(this.port, this.address);
}

Future<List<int>> encodeServerInfoMessage(ServerSocket serverSocket) async {
  final l = await NetworkInterface.list(type: InternetAddressType.IPv4);
  final address = l.firstWhere((element) => element.addresses[0].address.startsWith("192.168."));
  final json = {
    "type": "ServerInfoMessage",
    "port": serverSocket.port,
    "address": address.addresses[0].address,
  };
  return utf8.encode(jsonEncode(json));
}

ServerInfoMessage decodeServerInfoMessage(List<int> bytes) {
  final json = getJsonMessage("ServerInfoMessage", bytes);
  return ServerInfoMessage(json['port'], InternetAddress(json['address']));
}

List<int> encodeDeviceId(String id) {
  final json = {"type": "AdvertisementMessage", "id": id};

  return utf8.encode(jsonEncode(json));
}

dynamic decodeDeviceId(List<int> bytes) {
  final json = getJsonMessage("AdvertisementMessage", bytes);
  return json['id'];
}
