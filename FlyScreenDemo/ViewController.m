//
//  ViewController.m
//  FlyScreenDemo
//
//  Created by Charles.Yao on 2017/5/17.
//  Copyright © 2017年 com.pico. All rights reserved.
//

#import "ViewController.h"
#import "FlyScreenManager.h"

@interface ViewController ()<ZQ_FlyScreenDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FlyScreenManager shared].delegate = self;
    [self layoutSetting];
}

- (void)layoutSetting {
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeSystem];
    Button.frame = CGRectMake(0, 0, 150, 50);
    Button.backgroundColor = [UIColor cyanColor];
    Button.center = self.view.center;
    [self.view addSubview:Button];
    [Button setTitle:@"连接" forState:UIControlStateNormal];
    Button.layer.masksToBounds = YES;
    Button.layer.cornerRadius = 20;
    [Button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick {
    [[FlyScreenManager shared] registScoket];
}

#pragma mark - ZQ_FlyScreenDelegate

- (void)udpSocketConnectFailed {

    NSLog(@"Socket打开失败");
}

- (void)udpSocketReceiveMessageTimeout {

    NSLog(@"Socket已打开，接受消息超时");
}

- (void)udpSocketRequestVideoListWithBaseUrlStr:(NSString *)baseUrlStr {

    NSString *url = [FlyScreenManager shared].baseUrlStr;
    NSLog(@"成功收取消息:%@",url);
}

- (void)dealloc {
    [[FlyScreenManager shared] removeSocket];
}

@end
