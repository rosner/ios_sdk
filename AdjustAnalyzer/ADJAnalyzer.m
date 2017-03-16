//
//  ADJActivityHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJAnalyzer.h"
//#import "ADJActivityHandler.h"
//#import "ADJActivityState.h"
//#import "ADJPackageBuilder.h"
//#import "ADJPackageHandler.h"
//#import "ADJLogger.h"
//#import "ADJTimerCycle.h"
//#import "ADJTimerOnce.h"
#import "ADJUtil.h"
//#import "UIDevice+ADJAdditions.h"
//#import "ADJAdjustFactory.h"
//#import "ADJAttributionHandler.h"
//#import "NSString+ADJAdditions.h"
//#import "ADJSdkClickHandler.h"
//#import "ADJSessionParameters.h"

static BOOL sIsInit;

@implementation ADJAnalyzer

//typedef (^AnalyzerCallbackBlock)(NSString *, NSString *, NSString *);

+ (void)parseCookie:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
    
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResp allHeaderFields] forURL:[response URL]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:[response URL] mainDocumentURL:nil];
    for (NSHTTPCookie *cookie in cookies) {
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
        [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
        [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
        [cookieProperties setObject:[NSNumber numberWithInt:cookie.version] forKey:NSHTTPCookieVersion];
        
        [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:31536000] forKey:NSHTTPCookieExpires];
        
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        //        NSLog(@"encoded cookie: %@", cookie.value);
        
        //decode the first cookie's value
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:cookie.value options:0];
//        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        //        NSLog(@"decoded cookie: %@", decodedString);
        
        NSError *error;
        NSDictionary *cookieDict = [NSJSONSerialization JSONObjectWithData:decodedData options:kNilOptions error:&error];
        
        if(error != nil) {
            NSLog(@"Error parsing decoded cookie");
            return;
        }
        
        NSString *testSessionId = [cookieDict objectForKey:@"testSessionId"];
//        NSLog(@"session ID retrieved from cookie: %@", testSessionId);
        
        NSString *targetUrl = [NSString stringWithFormat:@"%@/%@", [ADJUtil baseUrl], testSessionId];
        
        NSLog(@"Test session url: %@", targetUrl);
        
        //set base url
        [ADJUtil setBaseUrl:targetUrl];
    }
}

+ (void)onReceiveTestCommand:(NSString *)funcName
                      params:(NSDictionary *)params
{
    if([funcName isEqual: @"onCreate"]) {
        NSString *appToken = [params objectForKey:@"appToken"][0];
        NSString *environment = [params objectForKey:@"environment"][0];
        
        ADJConfig *config = [ADJConfig configWithAppToken:appToken environment:environment];
        [config setLogLevel:ADJLogLevelVerbose];
        [Adjust appDidLaunch:config];
        [Adjust trackSubsessionStart];
    }
}

+ (void)init:(NSString *)baseUrl
      isInit:(BOOL)isInit
onReceiveCommand:(void (^)(NSString *callingClass, NSString *funcName, NSDictionary *params))onReceiveCommand
{
    NSLog(@">>> init");
    if(!onReceiveCommand) {
        NSLog(@"No callback received");
        return;
    }
    
    //set base url
    [ADJUtil setBaseUrl:baseUrl];
    
    // making a POST request to /init
    NSString *targetUrl = [NSString stringWithFormat:@"%@/init_session", baseUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Make an NSDictionary that would be converted to an NSData object sent over as JSON with the request body
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         @"basic_attribution", @"scenario_type",
                         nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:targetUrl]];
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable responseData,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          if (responseData == nil) {
              NSLog(@"Couldn't retrieve response from %@", targetUrl);
              return;
          }
          
          [ADJAnalyzer parseCookie:response];
          
          NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
          if (responseStr == nil || responseStr.length == 0) {
              return;
          }
          
          NSLog(@"Data received: %@", responseStr);
          
          NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData
                                                               options:kNilOptions
                                                                 error:&error];
          
          if(error != nil) {
              NSLog(@"Error parsing JSON.");
              return;
          }
          else {
              NSLog(@"Array: %@", jsonArray);
          }
          
          for (NSDictionary *dict in jsonArray) {
              NSString *callingClass = [dict objectForKey:@"className"];
              NSString *funcName = [dict objectForKey:@"functionName"];
//              NSString *params = [dict objectForKey:@"params"];
              NSDictionary *paramsDict = [dict objectForKey:@"params"];
              
//              NSMutableString *paramsStr = [NSMutableString stringWithString:@""];
//              NSString *delimiter = @"";
//              for (NSString* key in paramsDict) {
//                  NSString* value = (NSString *)[paramsDict objectForKey:key];
//                  [paramsStr appendString:delimiter];
//                  delimiter = @",,,";
//                  [paramsStr appendString:value];
//              }
//              
//              NSLog(@"ADJAnalyzer: calling Class: %@ || funcName: %@ || params: %@", callingClass, funcName, paramsStr);
              if([callingClass isEqual:@"TestLibrary"]) {
                  [ADJAnalyzer onReceiveTestCommand:funcName params:paramsDict];
              }
              else {
                  onReceiveCommand(callingClass, funcName, paramsDict);
              }
          }
          //
          //
          //                      for (NSString* key in jsonDict) {
          //          //                NSString* value = (NSString *)[jsonDict objectForKey:key];
          //
          //
          //                      }
          //
          //                      [jsonDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
          //                          NSLog(@"%@ = %@", key, object);
          //                      }];
          
          
      }] resume];
}



@end
