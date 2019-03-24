#import "FlutterNetworkUtilsPlugin.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


@implementation FlutterNetworkUtilsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_network_utils"
            binaryMessenger:[registrar messenger]];
  FlutterNetworkUtilsPlugin* instance = [[FlutterNetworkUtilsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getWifiSSID" isEqualToString:call.method]) {
      NSString *ssid = nil;
      NSArray *ssids = (__bridge_transfer id)CNCopySupportedInterfaces();
      
      for (NSString *name in ssids) {
          NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);
          if (info[@"SSID"]) {
              ssid = info[@"SSID"];
          }
      }
    result(ssid);
  } else if( [@"getWifiBSSID" isEqualToString:call.method]) {
      NSString *bssid = nil;
      NSArray *interfaces = (__bridge_transfer id)CNCopySupportedInterfaces();
      
      for (NSString *name in interfaces) {
          NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);
          if (info[@"BSSID"]) {
              bssid = info[@"BSSID"];
          }
      }
      result(bssid);
  } else if( [@"getWifiIP" isEqualToString:call.method]) {
      NSString* ipAddress = [self getIPAddress4];
    result(ipAddress);
  }else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

- (NSString *)getIPAddress4
{
    NSString *key = [NSString stringWithFormat:@"%@/%@",IOS_WIFI,IP_ADDR_IPv4];
    NSString *ipv4 = [[self getIPAddresses]objectForKey:key];
    return ipv4;
}

- (NSString *)getIpAddress6
{
    NSString *key = [NSString stringWithFormat:@"%@/%@",IOS_WIFI,IP_ADDR_IPv6];
    NSString *ipv6 = [[self getIPAddresses]objectForKey:key];
    return ipv6;
}

@end
