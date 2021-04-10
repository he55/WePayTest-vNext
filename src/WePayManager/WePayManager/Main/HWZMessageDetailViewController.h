//
//  HWZMessageDetailViewController.h
//  WePayManager
//
//  Created by 何伟忠 on 6/4/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWZWeChatMessageItem;

NS_ASSUME_NONNULL_BEGIN

@interface HWZMessageDetailViewController : UIViewController

@property (nonatomic, strong) HWZWeChatMessageItem *messageItem;

@end

NS_ASSUME_NONNULL_END
