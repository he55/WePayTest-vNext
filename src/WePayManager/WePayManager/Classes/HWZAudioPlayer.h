//
//  HWZAudioPlayer.h
//  WePayManager
//
//  Created by 何伟忠 on 5/22/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWZAudioPlayer : NSObject

+ (instancetype)sharedAudioPlayer;

- (void)play;
- (void)pause;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
