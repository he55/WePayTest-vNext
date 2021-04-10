//
//  HWZWebServer.m
//  WePay
//
//  Created by 何伟忠 on 5/19/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#include <notify.h>
#import "HWZWebServer.h"
#import "HWZWeChatMessage.h"
#import "GCDWebServer/GCDWebServers.h"

@interface HWZWebServer () {
    GCDWebServer *_webServer;
}

@end


@implementation HWZWebServer

+ (instancetype)sharedWebServer {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        _webServer = [[GCDWebServer alloc] init];
        [self addHandler];
    }
    return self;
}


- (void)addHandler {
    __weak __typeof__(self) weakSelf = self;
    [_webServer addHandlerForMethod:@"GET" path:@"/status" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        return [GCDWebServerDataResponse responseWithText:[NSString stringWithFormat:@"%@ %d", strongSelf->_webServer.serverURL, getpid()]];
    }];

    [_webServer addHandlerForMethod:@"GET" path:@"/restart" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        completionBlock([GCDWebServerDataResponse responseWithText:@"ok"]);
        [NSThread sleepForTimeInterval:0.3];
        exit(0);
    }];

    [_webServer addHandlerForMethod:@"GET" path:@"/api/message" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        NSString *sid = request.query[@"sid"];
        if (!sid) {
            return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_BadRequest message:@"请求参数错误"];
        }

        NSDictionary *message = [HWZWeChatMessage messageWithMessageId:sid];
        if (!message) {
            return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError message:@"服务器内部错误"];
        }

        return [GCDWebServerDataResponse responseWithJSONObject:message contentType:@"application/json; charset=utf-8"];
    }];

    [_webServer addHandlerForMethod:@"GET" path:@"/api/messages" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        NSString *timestamp = request.query[@"t"];
        if (!timestamp) {
            return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_BadRequest message:@"请求参数错误"];
        }

        NSArray *messages = [HWZWeChatMessage messagesWithTimestamp:[timestamp integerValue]];
        if (!messages) {
            return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError message:@"服务器内部错误"];
        }

        return [GCDWebServerDataResponse responseWithJSONObject:messages contentType:@"application/json; charset=utf-8"];
    }];

    [_webServer addHandlerForMethod:@"GET" path:@"/api/make_order" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        float orderAmount = request.query[@"orderAmount"].floatValue;
        NSString *orderId = request.query[@"orderId"];

        if (orderAmount < 0.01 || orderId.length == 0 || [orderId containsString:@"::"]) {
            return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_BadRequest message:@"请求参数错误"];
        }

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"werq::%@::%.2f", orderId, orderAmount];

        notify_post("com.hwz.wepay.makeOrder");

        int i = 0;
        while (i < 10) {
            i++;
            [NSThread sleepForTimeInterval:0.3];

            if (pasteboard.hasStrings) {

                NSArray<NSString *> *orderStrings = [pasteboard.string componentsSeparatedByString:@"::"];
                if ([orderStrings.firstObject isEqualToString:@"wers"] && [orderStrings[1] isEqualToString:orderId]) {

                    if (!request.query[@"f"]) {
                        return [GCDWebServerDataResponse responseWithText:orderStrings[3]];
                    }

                    return [GCDWebServerDataResponse responseWithJSONObject:@{
                        @"orderId": orderStrings[1],
                        @"orderAmount": orderStrings[2],
                        @"orderCode": orderStrings[3],
                    } contentType:@"application/json; charset=utf-8"];
                }
            }
        }

        return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError message:@"支付请求服务等待超时，请检查 iPhone 确保 WeChat 处于前台"];
    }];
}


- (BOOL)startWithPort:(NSUInteger)port {
    NSDictionary *options = @{
        GCDWebServerOption_Port: @(port),
        GCDWebServerOption_AutomaticallySuspendInBackground: @NO
    };

    return [_webServer startWithOptions:options error:nil];
}

@end
