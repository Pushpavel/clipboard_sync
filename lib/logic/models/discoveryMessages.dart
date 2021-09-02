import 'dart:convert';

import 'dart:io';

import 'package:clipboard_sync/logic/models/messages.dart';

class ServerInfoMessage {
  final int port;
  final List<InternetAddress> addresses;

  ServerInfoMessage(this.port, this.addresses);
}

Future<List<int>> encodeServerInfoMessage(ServerSocket serverSocket) async {
  final l = await NetworkInterface.list(type: InternetAddressType.IPv4);
  final addresses = l
      .where((element) => !element.addresses[0].address.startsWith("127.0."))
      .map((e) => e.addresses[0].address)
      .toList();
  final json = {
    "type": "ServerInfoMessage",
    "port": serverSocket.port,
    "addresses": addresses,
  };
  return utf8.encode(jsonEncode(json));
}

ServerInfoMessage decodeServerInfoMessage(List<int> bytes) {
  final json = getJsonMessage("ServerInfoMessage", bytes);
  final addresses = json['addresses'] as List<dynamic>;
  return ServerInfoMessage(json['port'], addresses.map((e) => InternetAddress(e)).toList());
}

List<int> encodeDeviceId(String id) {
  final json = {"type": "AdvertisementMessage", "id": id};

  return utf8.encode(jsonEncode(json));
}

dynamic decodeDeviceId(List<int> bytes) {
  final json = getJsonMessage("AdvertisementMessage", bytes);
  return json['id'];
}
