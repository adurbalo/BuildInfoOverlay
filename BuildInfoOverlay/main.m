//
//  main.m
//  BuildInfoOverlay
//
//  Created by Andrey Durbalo on 24.03.14.
//  Copyright (c) 2014 Andrey Durbalo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"
#import "ImageProcessingManager.h"

void showHelp();

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        if ( argc <= 1 ){
            showHelp();
            return EXIT_SUCCESS;
        }
        
        NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];
        for (int i = 0; i < argc; i++) {
            NSString *argument = [NSString stringWithUTF8String:argv[i]];
            [args addObject:argument];
        }
        
        SettingsManager *settingMgr = [SettingsManager sharedSettingsManager];
        if ( ![settingMgr setLaunchArguments:args] ){
            return EXIT_FAILURE;
        }
        
        [[ImageProcessingManager sharedImageProcessingManager] generateImages];
    
        return EXIT_SUCCESS;
    }
    
    return 0;
}

void showHelp()
{
    printf("Hello, if you see this message - something went wrong.\n");
    printf("Run this app with parameters --version: <app_version> --buildType: <build_type> --sourceImagePath: <source_image_path> --targetDirPath: <target_dir_path>");
}

