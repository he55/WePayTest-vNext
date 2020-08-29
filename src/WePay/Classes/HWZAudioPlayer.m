//
//  HWZAudioPlayer.m
//  WePayManager
//
//  Created by 何伟忠 on 5/22/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZAudioPlayer.h"
#import <AVKit/AVKit.h>

@interface HWZAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end


@implementation HWZAudioPlayer

+ (instancetype)sharedAudioPlayer {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"blank_sound.wav" withExtension:nil];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _audioPlayer.numberOfLoops = -1;
        _audioPlayer.volume = 0.01;
        [_audioPlayer prepareToPlay];
    }
    return _audioPlayer;
}


- (void)play {
    if (!self.audioPlayer.isPlaying) {
        [self.audioPlayer play];
    }
}


- (void)pause {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer pause];
    }
}

@end
