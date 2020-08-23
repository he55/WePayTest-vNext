//
//  HWZSettings.m
//  WePay
//
//  Created by 何伟忠 on 6/14/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZSettings.h"

NSString * HWZDbPath;
NSString * HWZTableName;

@implementation HWZSettings

+ (BOOL)loadSettings {
    NSString *path = @"/var/mobile/WePaySettings.plist";
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }

    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    HWZDbPath = dict[@"dbPath"];
    HWZTableName = dict[@"tableName"];

    if (!HWZDbPath || !HWZTableName) {
        return NO;
    }
    return YES;
}

@end
