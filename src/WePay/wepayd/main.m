#include <stdio.h>
#import "HWZWebServer.h"
#import "HWZSettings.h"

static NSURLSession *urlSession;

static void notificationCallback(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo) {
    if (!HWZOrderServiceCallbackURL) {
        return;
    }

    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:[NSURL URLWithString:HWZOrderServiceCallbackURL]];
    [dataTask resume];
}

int main(int argc, char *argv[], char *envp[]) {
    if (![HWZSettings loadSettings]) {
        goto lp;
    }
    
    char *webServerPort = getenv("_WebServerPort");
    if (!webServerPort) {
        goto lp;
    }
    
    NSInteger port = [@(webServerPort) integerValue];
    if (port == 0) {
        goto lp;
    }
    
    [[HWZWebServer sharedWebServer] startWithPort:port];
    urlSession = [NSURLSession sharedSession];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    notificationCallback,
                                    CFSTR("com.hwz.wepay.unreadCountChange"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDrop);
    
lp:
    CFRunLoopRun();
    return 0;
}
