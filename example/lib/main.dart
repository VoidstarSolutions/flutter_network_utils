import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_network_utils/flutter_network_utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _ssid = 'Unknown';
  String _bssid = 'Unkown';
  String _ip = 'Unkown';
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String ssid, bssid, ip;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      ssid = await FlutterNetworkUtils.wifiSsid;
      bssid = await FlutterNetworkUtils.wifiBssid;
      ip = await FlutterNetworkUtils.wifiIp;

    } on PlatformException {
      ssid = 'Error Retrieving Network Info';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _ssid = ssid;
      _bssid = bssid;
      _ip = ip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text('Connected to $_ssid\n'),
            Text('BSSID: $_bssid\n'),
            Text('IP: $_ip\n'),
          ],
        )),
      ),
    );
  }
}
