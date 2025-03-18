import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = {};

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceData = {
      'platform': 'Android',
      'device': androidInfo.model,
      'brand': androidInfo.brand,
      'version': androidInfo.version.release,
      'sdkInt': androidInfo.version.sdkInt,
    };
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceData = {
      'platform': 'iOS',
      'device': iosInfo.model,
      'systemVersion': iosInfo.systemVersion,
    };
  }

  return deviceData;
}
