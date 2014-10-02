//
//  SettingsManager.h
//  wadl2objc
//
//  Created by Dmitry on 8/26/13.
//  Copyright (c) 2013 zimCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

static NSString * const kVersionArgumentKey     = @"--version:";
static NSString * const kVersionTextColorArgumentKey     = @"--versionTextColor:";
static NSString * const kBuildTypeArgumentKey   = @"--buildType:";
static NSString * const kBuildTypeTextColorArgumentKey   = @"--buildTypeTextColor:";
static NSString * const kSourceImagePathKey     = @"--sourceImagePath:";
static NSString * const kTargetDirPathKey       = @"--targetDirPath:";
static NSString * const kOutputImageNameKey     = @"--outputImageName:";
static NSString * const kOutputImageWidthKey    = @"--outputImageWidth:";
static NSString * const kOutputImageHeightKey   = @"--outputImageHeight:";

@interface SettingsManager : NSObject

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *versionTextColor;
@property (nonatomic, strong) NSString *buildType;
@property (nonatomic, strong) NSString *buildTypeTextColor;
@property (nonatomic, strong) NSString *sourceImagePath;
@property (nonatomic, strong) NSString *targetDirPath;
@property (nonatomic, strong) NSString *outputImageName;
@property (nonatomic, strong) NSString *outputImageWidth;
@property (nonatomic, strong) NSString *outputImageHeight;
@property (nonatomic, strong) NSString *applicationPath;

CWL_DECLARE_SINGLETON_FOR_CLASS(SettingsManager);

- (BOOL)setLaunchArguments:(NSArray*)args;

@end
