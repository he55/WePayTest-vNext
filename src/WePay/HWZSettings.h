//
//  HWZSettings.h
//  WePay
//
//  Created by 何伟忠 on 6/14/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nullable HWZDbPath;
extern NSString * _Nullable HWZTableName;

NS_ASSUME_NONNULL_BEGIN

@interface HWZSettings : NSObject

+ (BOOL)loadSettings;

@end

NS_ASSUME_NONNULL_END
