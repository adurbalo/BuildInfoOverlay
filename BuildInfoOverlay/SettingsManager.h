//
//  SettingsManager.h
//  wadl2objc
//
//  Created by Dmitry on 8/26/13.
//  Copyright (c) 2013 zimCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

#define kVersionArgumentKey    @"--version:"
#define kBuildTypeArgumentKey    @"--buildType:"
#define kSourceImagePath @"--sourceImagePath:"
#define kTargetDirPath @"--targetDirPath:"

@interface SettingsManager : NSObject

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *buildType;
@property (nonatomic, strong) NSString *sourceImagePath;
@property (nonatomic, strong) NSString *targetDirPath;
@property (nonatomic, strong) NSString *applicationPath;

CWL_DECLARE_SINGLETON_FOR_CLASS(SettingsManager);

- (BOOL)setLaunchArguments:(NSArray*)args;

@end
