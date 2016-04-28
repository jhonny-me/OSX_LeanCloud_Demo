//
//  JCServerManager.m
//  YeZiNotify
//
//  Created by 顾强 on 16/4/15.
//  Copyright © 2016年 jhonny.copper. All rights reserved.
//

#import "JCServerManager.h"
#import <Cocoa/Cocoa.h>

@implementation JCServerManager

+ (instancetype)manager{
    static JCServerManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JCServerManager alloc] init];
    });
    return _manager;
}

- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    self.serverArray = [NSArray arrayWithContentsOfFile:path];
    [self switchServer:0];
    
    return self;
}

- (void)switchServer:(NSInteger)serverID{
    self.serverID = serverID;
    NSDictionary *dic = self.serverArray[serverID];
    self.applictionID = dic[@"kAVOSApplicationId"];
    self.clientKey = dic[@"kAVOSClientKey"];
}

+ (void)showAlertViewMessage:(NSString *)hint{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = hint;
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

@end
