//
//  SceneDelegate.h
//  WePayManager
//
//  Created by 何伟忠 on 5/18/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWZTabBarController;

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (nonatomic, strong) HWZTabBarController *tabBarController;

@end

