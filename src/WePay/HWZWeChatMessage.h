//
//  HWZWeChatMessage.h
//  WePay
//
//  Created by 何伟忠 on 5/19/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWZWeChatMessage : NSObject

+ (NSDictionary<NSString *, id> *)messageWithMessageId:(NSString *)messageId;
+ (NSArray<NSDictionary<NSString *, id> *> *)messagesWithTimestamp:(NSInteger)timestamp;

@end

NS_ASSUME_NONNULL_END
