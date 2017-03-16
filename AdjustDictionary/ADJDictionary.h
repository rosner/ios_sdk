//
//  ADJDictionary.m
//  testanalyzer
//
//  Created by Abdullah Obaied on 09/03/2017.
//  Copyright © 2017 Abdullah Obaied. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adjust.h"

@protocol DictProtocol <NSObject>

+ (void)receiveCommand:(NSString *)funcName
    paramsDict:(NSDictionary *)paramsDict;

@end

@interface ADJDictionary : NSObject

+ (void)executeCommand:(NSString *)callingClass
    funcName:(NSString *)funcName
    paramsDict:(NSDictionary *)paramsDict;

@end

@interface ADJDictionary_Adjust : NSObject <DictProtocol>
@end

@interface ADJDictionary_Foo : NSObject <DictProtocol>
@end

@interface ADJDictionary_System : NSObject <DictProtocol>
@end

@interface ADJDictionary_TestLibrary : NSObject <DictProtocol>
@end
