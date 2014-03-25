//
//  SettingsManager.m
//  wadl2objc
//
//  Created by Dmitry on 8/26/13.
//  Copyright (c) 2013 zimCo. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(SettingsManager);

- (NSString *)argsArray:(NSMutableArray*)argsArray popArgumentForKey:(NSString*)argumentKey
{
    NSUInteger index = [argsArray indexOfObject:argumentKey];
    if (index == NSNotFound){
        NSLog(@"Missing parameter: %@ ", argumentKey);
        return nil;
    }
    NSString *result = argsArray[index + 1];
    [argsArray removeObjectAtIndex:index];
    [argsArray removeObjectAtIndex:index];
    return result;
}

- (BOOL)setLaunchArguments:(NSArray *)args
{
    NSMutableArray *argsArray = [NSMutableArray arrayWithArray:args];
    
    if (argsArray.count > 0) {
        self.applicationPath = argsArray[0];
        [argsArray removeObjectAtIndex:0];
    }
    
    self.version = [self argsArray:argsArray popArgumentForKey:kVersionArgumentKey];
    self.buildType = [self argsArray:argsArray popArgumentForKey:kBuildTypeArgumentKey];
    self.sourceImagePath = [self argsArray:argsArray popArgumentForKey:kSourceImagePath];
    self.targetDirPath = [self argsArray:argsArray popArgumentForKey:kTargetDirPath];
   
    if ( argsArray.count ){
        NSLog(@"Unexpected parameters: %@", argsArray);
        return NO;
    }
    
    if ( _version && _buildType && _sourceImagePath && _targetDirPath){
        return YES;
    }
    
    return NO;
}

@end
