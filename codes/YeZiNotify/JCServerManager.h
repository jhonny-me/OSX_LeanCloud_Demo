//
//  JCServerManager.h
//  YeZiNotify
//
//  Created by 顾强 on 16/4/15.
//  Copyright © 2016年 jhonny.copper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCServerManager : NSObject

@property (strong, nonatomic) NSArray<NSDictionary *> *serverArray;

@property (copy, nonatomic) NSString *applictionID;

@property (copy, nonatomic) NSString *clientKey;

@property (assign) NSInteger serverID;

+ (instancetype)manager;

- (void)switchServer:(NSInteger)serverID;

+ (void)showAlertViewMessage:(NSString *)hint;

@end
