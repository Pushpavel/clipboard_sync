import 'package:clipboard_sync/logic/models/info.dart';
import 'package:clipboard_sync/logic/network/advertise.dart';
import 'package:clipboard_sync/logic/network/discover.dart';
import 'package:clipboard_sync/logic/utils/uuid.dart';

class ConnectionService {
  final DeviceInfo deviceInfo;

  final client = Client();
  final advertiser = Advertiser();

  static ConnectionService? _instance;

  ConnectionService(this.deviceInfo);

  static instance() async {
    if (_instance != null) return _instance!;
    final deviceInfo = await getDeviceInfo();
    if (deviceInfo == null) throw Exception("DeviceInfo: unique id of device cannot be determined");

    final service = ConnectionService(deviceInfo);
    _instance = service;

    service.advertiser.start(service.deviceInfo);
    return service;
  }
}
