import 'dart:io';

import 'package:clipboard_sync/logic/clipboard/clipboard.dart';
import 'package:clipboard_sync/logic/models/messages.dart';
import 'package:rxdart/rxdart.dart';

const KEEP_ALIVE_INTERVAL = Duration(seconds: 1);

handleClient(BehaviorSubject<List<Socket>> sockets, Socket socket) async {
  String socketValue = "";
  final sub = clipboard.listen((value) {
    if (socketValue != value.value) {
      final clipboardValue = encodeClipboardValue(value);
      print("sending $clipboardValue");
      socket.write(clipboardValue);
    }
  });

  socket.listen((event) {
    if (String.fromCharCodes(event).trim() == "alive") return;

    final clipboardValue = decodeClipboardValue(event);
    if (clipboard.value.value != clipboardValue.value &&
        clipboardValue.timestamp.compareTo(clipboardValue.timestamp) >= 0) {
      print("receiving ${String.fromCharCodes(event).trim()}");
      socketValue = clipboardValue.value;
      clipboard.value = clipboardValue;
    }
  });

  while (sockets.value.contains(socket)) {
    await Future.delayed(KEEP_ALIVE_INTERVAL);
    socket.write("alive");
  }

  sub.cancel();
}
