//
//  MyClass.h
//  NodeJS
//
//  Created by Admin on 6/23/20.
//

#ifndef _LISTENER_H
#define _LISTENER_H

@interface BridgeMsg : NSObject
- (id)initMsg:(NSString*)channel msg:(NSString*)msg;
@property(nonatomic, strong) NSString* channel;
@property(nonatomic, strong) NSString* msg;
@end

@interface Listener : NSObject {
}
+ (void)setDelegate:(id)delegate;
+ (void)callToNativeScript:(NSString*)msg;
+ (void)sendMessageToNode:(NSString*)channelName msg:(NSString*)msg;
+ (void)registerReceiver;
@end

@interface NSObject(MyDelegateMethods)
- (void)doCall:(NSString*)msg;
@end

#endif /* _LISTENER_H */
