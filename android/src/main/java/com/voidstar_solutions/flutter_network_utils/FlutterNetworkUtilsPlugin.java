package com.voidstar_solutions.flutter_network_utils;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterNetworkUtilsPlugin */
public class FlutterNetworkUtilsPlugin implements MethodCallHandler {
  private Context mContext;
  private ConnectivityManager mConnectivityManager;
  private WifiManager mWifiManager;

  private FlutterNetworkUtilsPlugin(Context context) {
    mContext = context.getApplicationContext();
    mConnectivityManager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    mWifiManager = (WifiManager) mContext.getSystemService(Context.WIFI_SERVICE);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_network_utils");
    channel.setMethodCallHandler(new FlutterNetworkUtilsPlugin(registrar.context()));
    if (isSDKAtLeastP() && registrar.activity()
        .checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
      registrar.activity().requestPermissions(new String[] { Manifest.permission.ACCESS_COARSE_LOCATION }, 1);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getWifiSSID")) {
      result.success(getCurrentSSID());
    } else if (call.method.equals("getWifiBSSID")) {
      result.success(getCurrentBSSID());
    } else if (call.method.equals("getWifiIP")) {
      result.success(getCurrentIP());
    } else {
      result.notImplemented();
    }
  }

  private static boolean isSDKAtLeastP() {
    return Build.VERSION.SDK_INT >= 28;
  }

  private String getCurrentSSID() {
    String ssid = null;
    NetworkInfo networkInfo = mConnectivityManager.getActiveNetworkInfo();
    if (networkInfo.isConnected()) {
      final WifiInfo connectionInfo = mWifiManager.getConnectionInfo();
      if (connectionInfo != null && connectionInfo.getSSID().length() > 0) {
        ssid = connectionInfo.getSSID();
      }
    }
    return ssid;
  }

  private String getCurrentBSSID() {
    String bssid = null;
    NetworkInfo networkInfo = mConnectivityManager.getActiveNetworkInfo();
    if (networkInfo.isConnected()) {
      final WifiInfo connectionInfo = mWifiManager.getConnectionInfo();
      if (connectionInfo != null && connectionInfo.getBSSID() != null) {
        bssid = connectionInfo.getBSSID();
      }
    }
    return bssid;
  }

  private String getCurrentIP() {
    int ip = 0;
    String ipString = null;
    NetworkInfo networkInfo = mConnectivityManager.getActiveNetworkInfo();
    if (networkInfo.isConnected()) {
      final WifiInfo connectionInfo = mWifiManager.getConnectionInfo();
      if (connectionInfo != null) {
        ip = connectionInfo.getIpAddress();
        int a = 0x000000ff & ip;
        int b = (0x0000ff00 & ip) >> 8;
        int c = (0x00ff0000 & ip) >> 16;
        int d = (0xff000000 & ip) >> 24;
        ipString = a + "." + b + "." + c + "." + d;
      }
    }
    return ipString;
  }
}
