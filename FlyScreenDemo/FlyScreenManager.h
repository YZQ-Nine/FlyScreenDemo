//
//  FlyScreenManager.h
//  FlyScreen_Demo
//
//  Created by Charles.Yao on 2017/5/17.
//  Copyright © 2017年 com.pico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

@protocol ZQ_FlyScreenDelegate <NSObject>

- (void)udpSocketConnectFailed;

- (void)udpSocketReceiveMessageTimeout;

- (void)udpSocketRequestVideoListWithBaseUrlStr:(NSString *)baseUrlStr;

@end

@interface FlyScreenManager : NSObject

singleton_interface(FlyScreenManager)

@property (nonatomic, copy)   NSString *baseUrlStr;

@property (nonatomic, weak) id<ZQ_FlyScreenDelegate> delegate;

- (void)registScoket;

- (void)removeSocket;

@end
