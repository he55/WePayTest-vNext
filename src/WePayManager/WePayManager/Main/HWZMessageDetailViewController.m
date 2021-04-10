//
//  HWZMessageDetailViewController.m
//  WePayManager
//
//  Created by 何伟忠 on 6/4/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZMessageDetailViewController.h"
#import "HWZWeChatMessageItem.h"
#import "HWZWeChatMessage.h"
#import "HWZHelper.h"

@interface HWZMessageDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation HWZMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStylePlain target:self action:@selector(handleShare)];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = self.messageItem.messageId;
    
    HWZWeChatMessageItem *message = [HWZWeChatMessage messageWithMessageId:self.messageItem.messageId];
    self.messageItem = message;
    
    if (!message) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.textView.text = @"";
        [HWZHelper alertWithViewController:self message:@"找不到对应数据"];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.textView.text = message.message;
}


- (void)handleShare {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.messageItem.message] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
