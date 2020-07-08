//
//  Listener.m
//  NodeJS
//
//  Created by Admin on 6/23/20.
//

#import <Foundation/Foundation.h>
#import "Listener.hh"
#include "node-bridge.h"
static id delegate;
static bool isNodeReady;
static bool isNativeScriptReady;
static NSMutableArray* arrayMsg;

@implementation BridgeMsg
- (id)initMsg:(NSString*)channel msg:(NSString*)msg; {
  self.channel = channel;
  self.msg = msg;
  return self;
}
@end

@implementation Listener
const char* SYSTEM_CHANNEL = "_SYSTEM_";

void triggerReady() {
  for (BridgeMsg* obj in arrayMsg) {
    if ([obj.channel isEqualToString:@""]) {
      [Listener callToNativeScript:obj.msg];
    } else {
      [Listener sendMessageToNode:obj.channel msg:obj.msg];
    }
  }
  arrayMsg = nil;
}

void handleAppChannelMessage(NSString* msg) {
  if ([msg isEqualToString:@"Node Ready"]) {
    isNodeReady = true;
    if (isNativeScriptReady) {
      triggerReady();
    }
  } else if ([msg isEqualToString:@"NativeScript Ready"]) {
    isNativeScriptReady = true;
    if (isNodeReady) {
      triggerReady();
    }
  } else if ([msg isEqualToString:@"Start Node"]) {
    //todo: start webview here
    [Listener callToNativeScript:@"test"];
  }
}

void sendMessageToApplication(const char* channelName, const char* msg) {
  @autoreleasepool
  {
    NSString* channelNameNS = [NSString stringWithUTF8String:channelName];
    NSString* msgNS = [NSString stringWithUTF8String:msg];
    if ([channelNameNS isEqualToString:[NSString stringWithUTF8String:SYSTEM_CHANNEL]]) {
      // If it's a system channel call, handle it in the plugin native side.
      handleAppChannelMessage(msgNS);
    } else {
      // Otherwise, send it to Nativescript.
      [Listener callToNativeScript:msgNS];
    }
  }
}

+ (void)initialize {
  isNodeReady = false;
  isNativeScriptReady = false;
  arrayMsg = [[NSMutableArray alloc] init];
}

+ (void)setDelegate:(id)aDelegate {
  delegate = aDelegate;
  handleAppChannelMessage(@"NativeScript Ready");
}

+ (void)callToNativeScript:(NSString*)msg; {
  if (isNativeScriptReady) {
    [delegate doCall:msg];
  } else {
    BridgeMsg *msgToNativeScript = [[BridgeMsg alloc]initMsg:@"" msg:msg];
    [arrayMsg addObject:msgToNativeScript];
  }
}

+ (void) sendMessageToNode:(NSString*) channelName msg:(NSString*) msg; {
  if (isNodeReady) {
    SendMessageToNodeChannel((const char*)[channelName UTF8String], (const char*)[msg UTF8String]);
  } else {
    BridgeMsg *msgToNode = [[BridgeMsg alloc]initMsg:channelName msg:msg];
    [arrayMsg addObject:msgToNode];
  }
}

+ (void) registerReceiver {
  RegisterBridgeCallback(sendMessageToApplication);
}
@end


