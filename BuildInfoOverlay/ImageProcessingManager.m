//
//  DrawImageManager.m
//  BuildInfoOverlay
//
//  Created by Andrey Durbalo on 24.03.14.
//  Copyright (c) 2014 Andrey Durbalo. All rights reserved.
//

#import "ImageProcessingManager.h"
#import <AppKit/AppKit.h>
#import "SettingsManager.h"

@implementation ImageProcessingManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(ImageProcessingManager);

- (void)generateImages
{
    NSString *imagePath = [[SettingsManager sharedSettingsManager] sourceImagePath];
    
    NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    [self saveImage:sourceImage withName:@"icon.png" andSize:NSMakeSize(72, 72)];
    [self saveImage:sourceImage withName:@"icon@2x.png" andSize:NSMakeSize(144, 144)];
    [self saveImage:sourceImage withName:@"icon_iOS7.png" andSize:NSMakeSize(76, 76)];
    [self saveImage:sourceImage withName:@"icon_iOS7@2x.png" andSize:NSMakeSize(152, 152)];
}

- (NSImage*)preparedTargetImage:(NSImage*)source
{
    NSString *version = [[SettingsManager sharedSettingsManager] version];
    NSString *buildType = [[SettingsManager sharedSettingsManager] buildType];
    
    NSImage *image = [source copy];
    
    [image lockFocus];
    
    NSInteger realWidth = image.size.width;
    NSInteger realHeight = image.size.height;
    
    [image setSize:NSMakeSize(realWidth, realHeight)];
    
    CGFloat percentWidth = realWidth/100.f;
    CGFloat percentHeight = realHeight/100.f;
    
    //Draw version
    NSDictionary *versionAttributesDictionary = @{
                                                  NSForegroundColorAttributeName : [NSColor whiteColor],
                                                  NSFontAttributeName : [NSFont systemFontOfSize:percentHeight*10]
                                                  };
    
    NSRect versionBoundRect = [version boundingRectWithSize:NSMakeSize(percentWidth*100, percentHeight*15) options:NSStringDrawingDisableScreenFontSubstitution attributes:versionAttributesDictionary];
    versionBoundRect.origin.x = percentWidth*90 - versionBoundRect.size.width;
    versionBoundRect.origin.y = percentHeight*88;
    
    [version drawWithRect:versionBoundRect options:NSStringDrawingDisableScreenFontSubstitution attributes:versionAttributesDictionary];
    
    
    //Draw build type
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSCenterTextAlignment;
    
    NSDictionary *buildTypeAttributedDictionary = @{
                                                    NSForegroundColorAttributeName : [NSColor redColor],
                                                    NSFontAttributeName : [NSFont boldSystemFontOfSize:percentHeight*20],
                                                    NSParagraphStyleAttributeName : paragrapStyle
                                                    };
    
    NSRect buildTypeBoundRect = [version boundingRectWithSize:NSMakeSize(percentWidth*100, percentHeight*25) options:NSStringDrawingDisableScreenFontSubstitution attributes:buildTypeAttributedDictionary];
    buildTypeBoundRect.origin.x = 0;
    buildTypeBoundRect.origin.y = percentHeight*10;
    buildTypeBoundRect.size.width = percentWidth*100;
    
    [buildType drawWithRect:buildTypeBoundRect options:NSStringDrawingUsesDeviceMetrics attributes:buildTypeAttributedDictionary];
    
    
    [image unlockFocus];
    
    return image;
}

- (NSImage*)resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    
    [sourceImage drawInRect:targetFrame
                   fromRect:NSZeroRect       //portion of source image to draw
                  operation:NSCompositeCopy  //compositing operation
                   fraction:1.0              //alpha (transparency) value
             respectFlipped:YES              //coordinate system
                      hints:@{NSImageHintInterpolation:
                                  [NSNumber numberWithInt:NSImageInterpolationHigh]}];
    
    [targetImage unlockFocus];
    
    return targetImage;
}

- (void)saveImage:(NSImage*)source withName:(NSString*)imageName andSize:(NSSize)size
{
    NSImage *sourceImage = [self resizeImage:source size:size];
    sourceImage = [self preparedTargetImage:sourceImage];

    NSData *imageData = [sourceImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
    
    NSString *targetDirPath = [[SettingsManager sharedSettingsManager] targetDirPath];
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:targetDirPath isDirectory:&isDir];
    if (!exists || !isDir) {
        NSLog(@"Path doesn't exist: %@", targetDirPath);
        return;
    }
    
    NSString *targetFilePath = [targetDirPath stringByAppendingPathComponent:imageName];
    
    [imageData writeToFile:targetFilePath atomically:NO];
}

@end
