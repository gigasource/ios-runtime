#import <NativeScript.h>
#import <TNSExceptionHandler.h>
#import "NodeJSRunner.hh"
#import <WebKit/WebKit.h>

#ifndef NDEBUG
#include <TNSDebugging.h>
#endif

@interface BaseClass : NSObject
+ (void)baseStaticMethod;
@end

extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");

int main(int argc, char *argv[]) {
  @autoreleasepool {
    [TNSRuntime initializeMetadata:&startOfMetadataSection];
    TNSRuntime *runtime = [[TNSRuntime alloc]
        initWithApplicationPath:[NSBundle mainBundle].bundlePath];
    [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];
    TNSRuntimeInspector.logsToSystemConsole = YES;

    TNSInstallExceptionHandler();

#ifndef NDEBUG
    TNSEnableRemoteInspector(argc, argv, runtime);
#endif

    NSArray* arguments = nil;
    NSString* srcPath = [[NSBundle mainBundle] pathForResource:@"nodejs-project/app-android.js" ofType:@""];
    arguments = [NSArray arrayWithObjects:
                    @"node",
                    srcPath,
                    @"--mode=iOS",
                 nil];
    [NodeJSRunner startEngineWithArguments:arguments];

    [runtime executeModule:@"./"];

    return 0;
  }
}
