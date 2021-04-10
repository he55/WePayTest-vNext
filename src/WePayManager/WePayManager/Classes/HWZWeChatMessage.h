//
//  HWZWeChatMessage.h
//  WePayManager
//
//  Created by 何伟忠 on 5/19/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWZWeChatMessageItem;

NS_ASSUME_NONNULL_BEGIN

@interface HWZWeChatMessage : NSObject

+ (nullable NSString *)tableNameWithDbPath:(NSString *)dbPath;

+ (nullable HWZWeChatMessageItem *)messageWithMessageId:(NSString *)messageId;
+ (nullable NSArray<HWZWeChatMessageItem *> *)messagesWithTimestamp:(NSInteger)timestamp;

@end

NS_ASSUME_NONNULL_END
