//
//  ViewController.m
//  YeZiNotify
//
//  Created by 顾强 on 16/4/12.
//  Copyright © 2016年 jhonny.copper. All rights reserved.
//

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "DJProgressHUD.h"
#import "JCServerManager.h"
#import "JCBaseViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:@"saveToCloud" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverChanged:) name:@"serverChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToSetting) name:@"setting" object:nil];
    [self refreshCurrentView];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)save{
    [DJProgressHUD showStatus:@"保存中" FromView:self.view];
    NSMutableAttributedString *string = self.textView.textStorage;
    NSError *err = nil;
    NSData *ddd = [string dataFromRange:NSMakeRange(0, string.length) documentAttributes:@{NSDocumentTypeDocumentAttribute:NSDocFormatTextDocumentType} error:&err];
    if (err) {
        NSLog(@"%@",err.localizedDescription);
        err = nil;
    }
    
    AVObject *obj = [AVObject objectWithClassName:@"Notice"];
    [obj setObject:ddd forKey:@"data"];
    
    [obj saveEventually:^(BOOL succeeded, NSError *error) {
        [DJProgressHUD dismiss];
        if (err) {
            [JCServerManager showAlertViewMessage:err.localizedDescription];
        }else if (succeeded){
            [JCServerManager showAlertViewMessage:@"设置成功"];
        }
    }];
}

- (void)serverChanged:(NSInteger)serverID{

    [self refreshCurrentView];
}

- (void)jumpToSetting{
    JCBaseViewController *vc = [JCBaseViewController new];
    [self presentViewControllerAsModalWindow:vc];
}

- (void)refreshCurrentView{
    
    NSString *applictionID = [JCServerManager manager].applictionID;
    NSString *clientKey = [JCServerManager manager].clientKey;
    [[[NSApplication sharedApplication] mainWindow] setTitle:[NSString stringWithFormat:@"%ld号服务器",[JCServerManager manager].serverID +1]];
    [AVOSCloud setApplicationId:applictionID
                      clientKey:clientKey];
    [DJProgressHUD showStatus:@"加载中" FromView:self.view];
    [self showNewestNotice:^(NSString *err) {
        [DJProgressHUD dismiss];
        if (err) {
            [JCServerManager showAlertViewMessage:err];
        }
    }];
}

- (void)showNewestNotice:(void(^)(NSString *))completion{
    NSError *err = nil;
    
    AVQuery *query = [AVQuery queryWithClassName:@"Notice"];
    AVObject *obj = [[query findObjects] lastObject];
    
    if (err) {
        return completion(err.localizedDescription);
    }else if (!obj){
        return completion(@"尚未设置");
    }
    
    NSData *data = [obj objectForKey:@"data"];
    
    NSDictionary *dic = @{NSDocumentTypeDocumentAttribute:NSDocFormatTextDocumentType};
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithDocFormat:data documentAttributes:&dic];
    
    // 删除原有数据
    NSMutableAttributedString *originalString = self.textView.textStorage;

    [self.textView.textStorage deleteCharactersInRange:NSMakeRange(0, originalString.length)];

    [self.textView insertText:string];

    err = nil;
    NSDataDetector * dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&err];
    if (err) {
        return completion(err.localizedDescription);
    }
    
    NSArray *matches = [dataDetector matchesInString:[string string] options:0 range:NSMakeRange(0, [string length])];
   
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            [_textView.textStorage addAttributes:@{NSLinkAttributeName:url.absoluteString} range:matchRange];
        }
    }
    completion(nil);
}

@end
