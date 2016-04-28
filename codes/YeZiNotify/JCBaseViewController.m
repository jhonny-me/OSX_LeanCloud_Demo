//
//  JCBaseViewController.m
//  YeZiNotify
//
//  Created by 顾强 on 16/4/15.
//  Copyright © 2016年 jhonny.copper. All rights reserved.
//

#import "JCBaseViewController.h"
#import "JCServerManager.h"
#import "DJProgressHUD.h"
#import <AVOSCloud/AVOSCloud.h>

@interface JCBaseViewController ()
@property (weak) IBOutlet NSTextFieldCell *textfield;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *textfields;

@end

@implementation JCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self refreshCurrentView];
}
- (IBAction)versionSubmitBtn_Pressed:(id)sender {
    NSString *string = [self.textfields stringValue];
    if (!string) {
        return;
    }
    AVObject *obj = [AVObject objectWithClassName:@"MyVersion"];
    [obj setObject:string forKey:@"data"];
    [DJProgressHUD showStatus:@"设置中" FromView:self.view];
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [DJProgressHUD dismiss];
        if (error) {
            [JCServerManager showAlertViewMessage:error.localizedDescription];
        }else if (succeeded){
            [JCServerManager showAlertViewMessage:@"设置成功"];
        }
    }];
}
- (IBAction)hintSubmitBtn_Pressed:(id)sender {
    [self save];
}

- (void)refreshCurrentView{
    
    NSString *applictionID = [JCServerManager manager].applictionID;
    NSString *clientKey = [JCServerManager manager].clientKey;
    self.title = [NSString stringWithFormat:@"%ld号服务器",[JCServerManager manager].serverID +1];

    [AVOSCloud setApplicationId:applictionID
                      clientKey:clientKey];
    [DJProgressHUD showStatus:@"加载中" FromView:self.view];
    [self showNewestInfo:^(NSString *err) {
        [DJProgressHUD dismiss];
        if (err) {
            [JCServerManager showAlertViewMessage:err];
        }
    }];
}

- (void)showNewestInfo:(void(^)(NSString *))completion{
    NSError *err = nil;
    
    AVQuery *query = [AVQuery queryWithClassName:@"MyVersion"];
    AVObject *obj = [[query findObjects] lastObject];
    
    if (obj) {
        NSString *string = [obj objectForKey:@"data"];
        
        [self.textfields setStringValue:string];
    }
    
    AVQuery *hintQuery = [AVQuery queryWithClassName:@"Hint"];
    AVObject *hintObj = [[hintQuery findObjects] lastObject];
    
    if (hintObj) {
        NSData *data = [hintObj objectForKey:@"data"];

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
    }
    completion(nil);
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
    
    AVObject *obj = [AVObject objectWithClassName:@"Hint"];
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

@end
