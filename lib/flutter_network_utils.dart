import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNetworkUtils {
  static const MethodChannel _channel =
      const MethodChannel('flutter_network_utils');

  static Future<String> get wifiSsid async {
    final String ssid = await _channel.invokeMethod('getWifiSSID');
    return ssid;
  }
  static Future<String> get wifiBssid async {
    final String bssid = await _channel.invokeMethod('getWifiBSSID');
    return bssid;
  }

  static Future<int> get wifiIp async {
    final int ip = await _channel.invokeMethod('getWifiIP');
    return ip;
  }
}
