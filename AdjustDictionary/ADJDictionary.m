//
//  ADJDictionary.m
//  testanalyzer
//
//  Created by Abdullah Obaied on 09/03/2017.
//  Copyright © 2017 Abdullah Obaied. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJDictionary.h"
#import "Adjust.h"
#import "ADJConfig.h"
#import "ADJAdjustFactory.h"

@implementation ADJDictionary

+ (void)executeCommand:(NSString *)callingClass
              funcName:(NSString *)funcName
                paramsDict:(NSDictionary *)paramsDict
{
    NSLog(@">>> ADJDictionary: ");
//    [[NSThread currentThread] isMainThread] ? NSLog(@"MAIN THREAD") : NSLog(@"NOT MAIN THREAD");
    
    if([callingClass isEqual: @"Adjust"]) {
        [ADJDictionary_Adjust receiveCommand:funcName paramsDict:paramsDict];
    } else if([callingClass isEqual: @"Foo"]) {
        [ADJDictionary_Foo receiveCommand:funcName paramsDict:paramsDict];
    } else if([callingClass isEqual: @"System"]) {
        [ADJDictionary_System receiveCommand:funcName paramsDict:paramsDict];
    }
}

@end

@implementation ADJDictionary_Adjust
+ (void)receiveCommand:(NSString *)funcName
                paramsDict:(NSDictionary *)paramsDict
{
    NSLog(@">>> ADJDictionary_Adjust: %@", funcName);
    [[NSThread currentThread] isMainThread] ? NSLog(@"MAIN THREAD") : NSLog(@"NOT MAIN THREAD");
    
    if([funcName isEqual: @"onCreate"]) {
        NSString *appToken = [paramsDict objectForKey:@"appToken"][0];
        NSString *environment = [paramsDict objectForKey:@"environment"][0];
        
        ADJConfig *config = [ADJConfig configWithAppToken:appToken environment:environment];
        [config setLogLevel:ADJLogLevelVerbose];
        [Adjust appDidLaunch:config];
        [Adjust trackSubsessionStart];
    }
    else if([funcName isEqual: @"teardown"]) {
        //BOOL deletedState = [[paramsDict objectForKey:@"deletedState"][0] isEqual:@"true"] ? TRUE : FALSE;
        [ADJAdjustFactory teardown];
    }
}

@end

@implementation ADJDictionary_System
+ (void)receiveCommand:(NSString *)funcName
            paramsDict:(NSDictionary *)paramsDict
{
    NSLog(@">>> ADJDictionary_System: ");
    
    if([funcName isEqual: @"sleep"]) {
        double delay = [[paramsDict objectForKey:@"millis"][0] doubleValue];

        NSLog(@"Sleeping...");
        [NSThread sleepForTimeInterval:delay];
        NSLog(@"Slept...");
    }
    
}
@end

@implementation ADJDictionary_Foo
+ (void)receiveCommand:(NSString *)funcName
                paramsDict:(NSDictionary *)paramsDict
{
    NSLog(@">>> ADJDictionary_Foo: ");
    
    if([funcName isEqual: @"fooTest"]) {
        NSLog(@"Sleeping...");
        [NSThread sleepForTimeInterval:10.0f];
        NSLog(@"Slept...");
    }
    
}

@end

@implementation ADJDictionary_TestLibrary
+ (void)receiveCommand:(NSString *)funcName
            paramsDict:(NSDictionary *)paramsDict
{
    NSLog(@">>> ADJDictionary_TestLibrary: ");
    
    if([funcName isEqual: @"end_test"]) {
        NSLog(@"test ended");
    }
}

@end
