//
//  AppDelegate.m
//  YeZiNotify
//
//  Created by 顾强 on 16/4/12.
//  Copyright © 2016年 jhonny.copper. All rights reserved.
//

#import "AppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import "JCServerManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[JCServerManager manager] switchServer:0];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)saveToCloud:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"saveToCloud" object:nil];
}
- (IBAction)firstServer:(id)sender {
    
    [[JCServerManager manager] switchServer:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverChanged" object:nil];
}
- (IBAction)secondServer:(id)sender {
    [[JCServerManager manager] switchServer:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverChanged" object:nil];
}
- (IBAction)thirdServer:(id)sender {
    [[JCServerManager manager] switchServer:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverChanged" object:nil];}
- (IBAction)settingBtn_Pressed:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setting" object:nil];
}


@end
