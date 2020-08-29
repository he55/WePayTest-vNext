//
//  HWZWeChatMessage.m
//  WePayManager
//
//  Created by 何伟忠 on 5/19/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZWeChatMessage.h"
#import "HWZWeChatMessageItem.h"
#import "FMDB.h"
#import "HWZSettings.h"

static NSString * const kConfirmMessage = @"123qwe";
static NSString * const kOpenDBFail = @"Open BrandMsg.db fail";

@implementation HWZWeChatMessage

+ (NSString *)tableNameWithDbPath:(NSString *)dbPath {
    if (!dbPath) {
        return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(kOpenDBFail);
        return nil;
    }
    
    
    FMResultSet *resultSet = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'chat/_%' ESCAPE '/' ORDER BY name"];
    if (!resultSet) {
        return nil;
    }
    
    NSMutableArray *chatTableNames = [NSMutableArray array];
    while ([resultSet next]) {
        [chatTableNames addObject:[resultSet stringForColumnIndex:0]];
    }
    
    for (NSString *chatTableName in chatTableNames) {
        resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT Message FROM %@ WHERE Des = 0 AND Type = 1 ORDER BY CreateTime DESC LIMIT 1", chatTableName]];
        if ([resultSet next] && [[resultSet stringForColumnIndex:0] isEqualToString:kConfirmMessage]) {
            [db close];
            return chatTableName;
        }
    }
    
    [db close];
    
    return nil;
}


+ (HWZWeChatMessageItem *)messageWithMessageId:(NSString *)messageId {
    if (!HWZDbPath || !HWZTableName) {
        return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:HWZDbPath];
    if (![db open]) {
        NSLog(kOpenDBFail);
        return nil;
    }
    
    
    static NSString * sql = @"SELECT CreateTime, MesSvrID, Message FROM %@ WHERE MesSvrID = ?";
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:sql, HWZTableName], messageId];
    
    if (!resultSet) {
        return nil;
    }
    
    if (![resultSet next]) {
        return nil;
    }
    
    HWZWeChatMessageItem *message = [[HWZWeChatMessageItem alloc] init];
    message.createTime = [resultSet intForColumnIndex:0];
    message.messageId = [resultSet stringForColumnIndex:1];
    message.message = [resultSet stringForColumnIndex:2];
    
    [db close];
    
    return message;
}


+ (NSArray<HWZWeChatMessageItem *> *)messagesWithTimestamp:(NSInteger)timestamp {
    if (!HWZDbPath || !HWZTableName) {
        return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:HWZDbPath];
    if (![db open]) {
        NSLog(kOpenDBFail);
        return nil;
    }
    
    
    static NSString * sql = @"SELECT CreateTime, MesSvrID FROM %@ WHERE Des = 1 AND Type = 49 AND CreateTime > ? AND Message LIKE '%%<![CDATA[we/_%%' ESCAPE '/' ORDER BY CreateTime";
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:sql, HWZTableName], @(timestamp)];
    
    if (!resultSet) {
        return nil;
    }
    
    NSMutableArray *messages = [NSMutableArray array];
    while ([resultSet next]) {
        HWZWeChatMessageItem *message = [[HWZWeChatMessageItem alloc] init];
        message.createTime = [resultSet intForColumnIndex:0];
        message.messageId = [resultSet stringForColumnIndex:1];
        [messages addObject:message];
    }
    
    [db close];
    
    return messages;
}

@end
