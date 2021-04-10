//
//  HWZWebServer.h
//  WePay
//
//  Created by 何伟忠 on 5/19/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWZWebServer : NSObject

+ (instancetype)sharedWebServer;
- (BOOL)startWithPort:(NSUInteger)port;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
