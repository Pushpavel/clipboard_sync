import 'package:clipboard_sync/logic/models/messages.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

final clipboard = BehaviorSubject<ClipboardValue>();

const updateInterval = const Duration(milliseconds: 500);

initializeClipboard() async {
  final value = await Clipboard.getData(Clipboard.kTextPlain);
  clipboard.value = ClipboardValue(value?.text ?? "", DateTime.now());

  clipboard.listen((value) => Clipboard.setData(ClipboardData(text: value.value)));

  while (true) {
    await Future.delayed(updateInterval);
    final newValue = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboard.value.value != newValue?.text) clipboard.value = ClipboardValue(newValue?.text ?? "", DateTime.now());
  }
}
