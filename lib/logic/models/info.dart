import 'dart:io';

class DeviceInfo {
  final String id;
  final String name;

  DeviceInfo(this.id, this.name);
}

class SocketInfo {
  final InternetAddress address;
  final int port;

  SocketInfo(this.address, this.port);
}
