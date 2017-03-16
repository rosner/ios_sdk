//
//  ADJActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"

@interface ADJAnalyzer : NSObject

+ (void)init:(NSString *)baseUrl
      isInit:(BOOL)isInit
onReceiveCommand:(void (^)(NSString *callingClass, NSString *funcName, NSDictionary *params))onReceiveCommand;

@end
