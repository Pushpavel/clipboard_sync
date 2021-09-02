import 'dart:io';

import 'package:clipboard_sync/logic/models/discoveryMessages.dart';
import 'package:clipboard_sync/logic/models/info.dart';
import 'package:clipboard_sync/logic/utils/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

const SERVER_PORT = 38899;
const SEARCH_PORT = 31000;
const SEARCH_SOURCE_PORT = 35560;
const SEARCH_INTERVAL = const Duration(seconds: 1);
const BROADCAST_ADDRESS = "255.255.255.255";

Future<ValueNotifier<Set<Socket>>> initializeNetwork() async {
  final socketStream = ValueNotifier(Set<Socket>.from([]));

  final deviceInfo = await getDeviceInfo();
  if (deviceInfo == null) throw Exception("DeviceInfo: unique id of device cannot be determined");
  final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, SERVER_PORT);

  serverSocket.listen((socket) {
    final list = socketStream.value.toSet();
    list.add(socket);
    socketStream.value = list;
  });

  _handleServerSearchers(deviceInfo, serverSocket);
  _searchServer(deviceInfo, socketStream);
  return socketStream;
}

_handleServerSearchers(DeviceInfo deviceInfo, ServerSocket serverSocket) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SEARCH_PORT);

  socket.readEventsEnabled = true;
  socket.writeEventsEnabled = true;
  socket.broadcastEnabled = true;

  socket.listen((event) {
    if (event != RawSocketEvent.read) return;
    final datagram = socket.receive()!;
    final id = decodeDeviceId(datagram.data);

    if (id.compareTo(deviceInfo.id) <= 0) return;

    final serverInfo = encodeServerInfoMessage(serverSocket);
    socket.send(serverInfo, datagram.address, datagram.port);
  });
}

_searchServer(DeviceInfo deviceInfo, ValueNotifier<Set<Socket>> socketStream) async {
  RawDatagramSocket? socket;

  socketStream.addListener((devices) async {
    if (devices.isNotEmpty) {
      socket?.close();
      socket = null;
    } else if (socket == null) {
      try {
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SEARCH_SOURCE_PORT);
        _handleServerConnections(socket!, socketStream);
      } finally {
        socket?.close();
        socket = null;
      }
    }
  } as VoidCallback);

  while (true) {
    await Future.delayed(SEARCH_INTERVAL);
    final deviceId = encodeDeviceId(deviceInfo.id);
    socket?.send(deviceId, InternetAddress(BROADCAST_ADDRESS), SEARCH_PORT);
  }
}

_handleServerConnections(RawDatagramSocket udpSocket, ValueNotifier<Set<Socket>> socketStream) {
  udpSocket.listen((event) async {
    if (event != RawSocketEvent.read) return;
    final datagram = udpSocket.receive()!;
    final serverMessage = decodeServerInfoMessage(datagram.data);
    if (socketStream.value.isNotEmpty) return;
    final socket = await Socket.connect(serverMessage.address, serverMessage.port);
    final list = socketStream.value.toSet();
    _removeSocketOnClose(socket, socketStream);
    list.add(socket);
    socketStream.value = list;
  });
}

_removeSocketOnClose(Socket socket, ValueNotifier<Set<Socket>> socketStream) async {
  try {
    await socket.done;
  } finally {
    final list = socketStream.value.toSet();
    list.remove(socket);
    socketStream.value = list;
  }
}
