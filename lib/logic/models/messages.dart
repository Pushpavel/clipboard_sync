import 'dart:convert';

class ClipboardMessage {
  final String originId;
  final String originName;
  final String value;

  ClipboardMessage(this.originId, this.originName, this.value);
}

getJsonMessage(String type, List<int> bytes) {
  final jsonString = String.fromCharCodes(bytes).trim();
  final json = jsonDecode(jsonString);

  if (json['type'] != type) throw Exception("unexpected json type, ${json.type} expected: $type");

  return json;
}
