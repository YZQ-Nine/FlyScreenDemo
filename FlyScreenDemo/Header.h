//
//  Header.h
//  FlyScreen_Demo
//
//  Created by Charles.Yao on 2017/5/17.
//  Copyright © 2017年 com.pico. All rights reserved.
//

#ifndef Header_h
#define Header_h

// @interface
#define singleton_interface(className) \
+ (className *)shared;


// @implementation
#define singleton_implementation(className) \
static className *_instance; \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (className *)shared \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
}


#endif /* Header_h */
