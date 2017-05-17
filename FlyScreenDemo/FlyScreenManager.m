//
//  FlyScreenManager.m
//  FlyScreen_Demo
//
//  Created by Charles.Yao on 2017/5/17.
//  Copyright © 2017年 com.pico. All rights reserved.
//

#import "FlyScreenManager.h"
#import <GCDAsyncUdpSocket.h>
#define udpPort 8080

@interface FlyScreenManager ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *clientSocket;
@property (nonatomic, assign) BOOL receivedSocketMessage;

@end

@implementation FlyScreenManager

singleton_implementation(FlyScreenManager)

- (instancetype)init{
    if(self = [super init]){
    }
    return self;
}

- (void)registScoket {
    
    if (!_clientSocket) {
        self.receivedSocketMessage = NO;
        self.baseUrlStr = nil;
        
        _clientSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError * error = nil;
        /*每次扫描，你会收到两条信息，IPv4和IPv6的，根据需求做取舍。*/
        [_clientSocket setIPv6Enabled:NO];
        [_clientSocket bindToPort:udpPort error:&error];
        if (error) {
            NSLog(@"clientSocket_error:%@",error);
            [self removeSocket];
            if (self.delegate && [self.delegate respondsToSelector:@selector(udpSocketConnectFailed)]) {
                [self.delegate udpSocketConnectFailed];
            }
        }else {
            [_clientSocket beginReceiving:&error];
            NSLog(@"socket打开 开始接收信息");
            /*开启后，如果5秒没收到数据，做超时处理*/
            [self performSelector:@selector(checkDidReceiveMessage) withObject:nil afterDelay:5.0];
        }
    }
}

#pragma mark - 关闭UDP监听
- (void)removeSocket {
    self.baseUrlStr = nil;
    if (_clientSocket) {
        [_clientSocket close];
        _clientSocket = nil;
    }
}

#pragma mark - UDP获取信息超时处理
- (void)checkDidReceiveMessage {
    if (!self.baseUrlStr) {
        [self removeSocket];
        if (self.delegate && [self.delegate respondsToSelector:@selector(udpSocketReceiveMessageTimeout)]) {
            [self.delegate udpSocketReceiveMessageTimeout];
        }
    }
}

#pragma mark - GCDAsyncUdpSocket delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    /*模拟收到的数据格式*/
    NSString *sendMessage = @"1$fly_screen$9000";
    
//    NSString *sendMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSLog(@"接收到%@的消息,\n解析到的数据[%@:%d]",sendMessage,ip,port);
    NSArray *messageArr = [sendMessage componentsSeparatedByString:@"$"];
    
    NSString *mark;
    if (messageArr.count == 3) {
        mark = messageArr[1];
    }
    
    /*给数据加一个标识，来区别是否是自家发来的广播*/
    if (![mark isEqualToString:@"fly_screen"]) {
        [self udpSocketInitiativeToStopListen];
        return;
    }
    self.baseUrlStr = [NSString stringWithFormat:@"http://%@:%@",ip,[messageArr lastObject]];
    
    /*因为广播是频发的，所以只接收成功的一次即可*/
    if (!self.receivedSocketMessage) {
        self.receivedSocketMessage = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(udpSocketRequestVideoListWithBaseUrlStr:)]) {
            [self.delegate udpSocketRequestVideoListWithBaseUrlStr:self.baseUrlStr];
        }
    }
    /*正常连接，15秒后，自动注销监听*/
    [self performSelector:@selector(udpSocketInitiativeToStopListen) withObject:nil afterDelay:15.0];
    
}

- (void)udpSocketInitiativeToStopListen {
    [self removeSocket];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"udpSocket关闭withError = %@", error);
}

@end
