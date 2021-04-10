//
//  HWZWeChatMessageItem.h
//  WePayManager
//
//  Created by 何伟忠 on 5/20/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWZWeChatMessageItem : NSObject

@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *message;

@end

NS_ASSUME_NONNULL_END
