//
//  HWZWeChatLocalInfo.h
//  WePayManager
//
//  Created by 何伟忠 on 5/20/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWZWeChatUserInfoItem;

NS_ASSUME_NONNULL_BEGIN

@interface HWZWeChatLocalInfo : NSObject

+ (nullable HWZWeChatUserInfoItem *)userInfo;

@end

NS_ASSUME_NONNULL_END
