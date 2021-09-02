import 'dart:convert';

class ClipboardValue {
  final String value;
  final DateTime timestamp;

  ClipboardValue(this.value, this.timestamp);
}

String encodeClipboardValue(ClipboardValue value) {
  final json = {
    "type": "ClipboardValue",
    "value": value.value,
    "timestamp": value.timestamp.millisecondsSinceEpoch,
  };

  return jsonEncode(json);
}

ClipboardValue decodeClipboardValue(String jsonString) {
  final json = getJsonMessage("ClipboardValue", utf8.encode(jsonString));
  return ClipboardValue(json['value'], DateTime.fromMillisecondsSinceEpoch(json['timestamp']));
}

getJsonMessage(String type, List<int> bytes) {
  final jsonString = String.fromCharCodes(bytes).trim();
  final json = jsonDecode(jsonString);

  if (json['type'] != type) throw Exception("unexpected json type, ${json.type} expected: $type");

  return json;
}
