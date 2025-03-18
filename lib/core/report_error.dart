import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/core/device_info.dart';

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  Map<String, dynamic> deviceInfo = await getDeviceInfo();

  final report = {
    'error': error.toString(),
    'stackTrace': stackTrace.toString(),
    'deviceInfo': deviceInfo,
    'timestamp': DateTime.now().toIso8601String(),
  };

  // Replace with your backend API URL
  const String apiUrl = "https://your-server.com/api/error-report";

  try {
    await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(report),
    );
  } catch (e) {
    debugPrint("Failed to send error report: $e");
  }
}
