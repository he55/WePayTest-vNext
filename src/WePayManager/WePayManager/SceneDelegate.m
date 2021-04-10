//
//  SceneDelegate.m
//  WePayManager
//
//  Created by 何伟忠 on 5/18/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "SceneDelegate.h"
#import "HWZTabBarController.h"
#import "HWZSettings.h"

static NSString * const kBackgroundTaskName = @"kBackgroundTaskName";

@interface SceneDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end


@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    if (![UIApplication sharedApplication].shortcutItems.count) {
        UIApplicationShortcutIcon *settingsIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove];
        UIApplicationShortcutItem *settingsItem = [[UIApplicationShortcutItem alloc] initWithType:@"settings" localizedTitle:@"设置" localizedSubtitle:nil icon:settingsIcon userInfo:nil];
        
        [UIApplication sharedApplication].shortcutItems = @[settingsItem];
    }
    
    [HWZSettings loadSettings];
    
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.tabBarController = [[HWZTabBarController alloc] init];
    
    if (connectionOptions.shortcutItem) {
        [self performActionForShortcutItem:connectionOptions.shortcutItem];
    }
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    
    // [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    
    /*
    __weak typeof(self) weakSelf = self;
    
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:kBackgroundTaskName expirationHandler:^{
        if (weakSelf.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTaskIdentifier];
            weakSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
    */
}


- (void)windowScene:(UIWindowScene *)windowScene performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [self performActionForShortcutItem:shortcutItem];
    completionHandler(YES);
}


- (void)performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    if ([shortcutItem.type isEqualToString:@"settings"]) {
        self.tabBarController.selectedIndex = 1;
    }
}

@end
