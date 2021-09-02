import 'dart:async';
import 'dart:io';

import 'package:clipboard_sync/logic/models/discoveryMessages.dart';
import 'package:clipboard_sync/logic/models/info.dart';
import 'package:clipboard_sync/logic/utils/uuid.dart';
import 'package:rxdart/rxdart.dart';

const SERVER_PORT = 10542;
const SEARCH_PORT = 38899;
const SEARCH_SOURCE_PORT = 40000;
const SEARCH_INTERVAL = const Duration(seconds: 1);
const BROADCAST_ADDRESS = "255.255.255.255";

BehaviorSubject<List<Socket>> initializeNetwork() {
  final socketStream = BehaviorSubject<List<Socket>>.seeded([]);
  _initializeNetwork(socketStream);
  return socketStream;
}

_initializeNetwork(BehaviorSubject<List<Socket>> socketStream) async {
  final l = await NetworkInterface.list(type: InternetAddressType.IPv4);
  l.forEach((element) {
    print(element.addresses[0].address);
  });

  final deviceInfo = await getDeviceInfo();
  if (deviceInfo == null) throw Exception("DeviceInfo: unique id of device cannot be determined");
  final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, SERVER_PORT);

  serverSocket.listen((socket) {
    final list = socketStream.value.toList();
    list.add(socket);
    socketStream.value = list;
  });

  _handleServerSearchers(deviceInfo, serverSocket);
  _searchServer(deviceInfo, socketStream);
}

_handleServerSearchers(DeviceInfo deviceInfo, ServerSocket serverSocket) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SEARCH_PORT);

  socket.readEventsEnabled = true;
  socket.writeEventsEnabled = true;
  socket.broadcastEnabled = true;

  socket.listen((event) async {
    if (event != RawSocketEvent.read) return;
    final datagram = socket.receive()!;
    final id = decodeDeviceId(datagram.data);

    if (id.compareTo(deviceInfo.id) <= 0) return;

    print(id);

    final serverInfo = await encodeServerInfoMessage(serverSocket);
    socket.send(serverInfo, datagram.address, datagram.port);
  });
}

_searchServer(DeviceInfo deviceInfo, BehaviorSubject<List<Socket>> socketStream) async {
  RawDatagramSocket? socket;
  manageSocket(List<Socket> sockets) async {
    if (sockets.isNotEmpty) {
      socket?.close();
      socket = null;
    } else if (socket == null) {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SEARCH_SOURCE_PORT);

      socket!.readEventsEnabled = true;
      socket!.writeEventsEnabled = true;
      socket!.broadcastEnabled = true;

      _handleServerConnections(socket!, socketStream);
    }
  }

  socketStream.listen(manageSocket);

  while (true) {
    await Future.delayed(SEARCH_INTERVAL);
    final deviceId = encodeDeviceId(deviceInfo.id);
    socket?.send(deviceId, InternetAddress(BROADCAST_ADDRESS), SEARCH_PORT);
  }
}

_handleServerConnections(RawDatagramSocket udpSocket, BehaviorSubject<List<Socket>> socketStream) {
  udpSocket.listen((event) async {
    if (event != RawSocketEvent.read) return;
    final datagram = udpSocket.receive()!;
    final serverMessage = decodeServerInfoMessage(datagram.data);
    for (final address in serverMessage.addresses) {
      try {
        if (socketStream.value.isNotEmpty) return;
        final socket = await Socket.connect(address, serverMessage.port);

        if (socketStream.value.isNotEmpty) {
          socket.close();
          return;
        }

        final list = socketStream.value.toList();
        _removeSocketOnClose(socket, socketStream);
        list.add(socket);
        socketStream.value = list;
      } catch (e) {
        print(e);
      }
    }
  });
}

_removeSocketOnClose(Socket socket, BehaviorSubject<List<Socket>> socketStream) async {
  try {
    await socket.done;
  } finally {
    final list = socketStream.value.toList();
    list.remove(socket);
    socketStream.value = list;
  }
}
