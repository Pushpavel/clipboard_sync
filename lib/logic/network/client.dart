import 'dart:io';

import 'package:clipboard_sync/logic/clipboard/clipboard.dart';
import 'package:clipboard_sync/logic/models/messages.dart';

handleClient(Socket socket) async {
  bool pause = false;

  clipboard.listen((value) {
    if (!pause) {
      final clipboardValue = encodeClipboardValue(value);
      socket.write(clipboardValue);
    }
  });

  socket.listen((event) {
    pause = true;
    final clipboardValue = decodeClipboardValue(event);
    if (clipboard.value.value != clipboardValue.value &&
        clipboardValue.timestamp.compareTo(clipboardValue.timestamp) >= 0) {
      clipboard.value = clipboardValue;
    }
    pause = false;
  });
}
