//
//  HWZHelper.m
//  WePayManager
//
//  Created by 何伟忠 on 6/4/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZHelper.h"

@implementation HWZHelper

+ (void)alertWithViewController:(UIViewController *)viewController message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAlertAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
