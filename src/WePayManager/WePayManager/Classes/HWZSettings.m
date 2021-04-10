//
//  HWZSettings.m
//  WePayManager
//
//  Created by 何伟忠 on 6/14/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZSettings.h"

NSString * HWZDbPath;
NSString * HWZTableName;
NSString * HWZOrderServiceURL;
NSString * HWZOrderServiceCallbackURL;

@implementation HWZSettings

+ (void)loadSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    HWZDbPath = [userDefaults stringForKey:@"dbPath"];
    HWZTableName = [userDefaults stringForKey:@"tableName"];
    HWZOrderServiceURL = [userDefaults stringForKey:@"orderServiceURL"];
    HWZOrderServiceCallbackURL = [userDefaults stringForKey:@"orderServiceCallbackURL"];
}


+ (BOOL)saveSettings {
    if (!HWZDbPath || !HWZTableName) {
        return NO;
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:HWZDbPath forKey:@"dbPath"];
    [userDefaults setObject:HWZTableName forKey:@"tableName"];
    [userDefaults setObject:HWZOrderServiceURL forKey:@"orderServiceURL"];
    [userDefaults setObject:HWZOrderServiceCallbackURL forKey:@"orderServiceCallbackURL"];
    [userDefaults synchronize];

    NSDictionary *dict = @{
        @"dbPath": HWZDbPath,
        @"tableName": HWZTableName ?: [NSNull null],
        @"orderServiceCallbackURL": HWZOrderServiceCallbackURL ?: [NSNull null]
    };
    [dict writeToFile:@"/var/mobile/WePaySettings.plist" atomically:YES];
    return YES;
}

@end
