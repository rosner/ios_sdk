//
//  ADJConfig.h
//  adjust
//
//  Created by Pedro Filipe on 30/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJLogger.h"
#import "ADJAttribution.h"

/**
 * Optional delegate that will get informed about tracking results
 */
@protocol  AdjustDelegate
@optional

/**
 * Optional delegate method that will get called when a tracking attempt finished
 *
 * @param responseData The response data containing information about the activity
 *     and it's server response. See AIResponseData for details.
 */
- (void)adjustAttributionCallback:(ADJAttribution *)attribution;

@end

@interface ADJConfig : NSObject<NSCopying>

@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, assign) ADJLogLevel logLevel;
@property (nonatomic, copy) NSString *environment;
@property (nonatomic, copy) NSString *sdkPrefix;
@property (nonatomic, assign) BOOL eventBufferingEnabled;
@property (nonatomic, assign) BOOL macMd5TrackingEnabled;
@property (nonatomic, retain) NSObject<AdjustDelegate> *delegate;

- (id)initWithAppToken:(NSString *)appToken andEnvironment:(NSString *)environment;
+ (ADJConfig*)configWithAppToken:(NSString *)appToken andEnvironment:(NSString *)environment;

@end
