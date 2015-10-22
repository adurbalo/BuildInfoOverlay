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

@interface ImageProcessingManager ()
{
    CGFloat _percentWidth;
    CGFloat _percentHeight;
}

@end

#define WIDTH_PERCENT(x) roundf(_percentWidth * (x))
#define HEIGHT_PERCENT(x) roundf(_percentHeight * (x))

@implementation ImageProcessingManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(ImageProcessingManager);

+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex {
    
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringWithRange:NSMakeRange(1, [hex length] - 1)];
    }
    
    unsigned int colorCode = 0;
    
    if (hex) {
        NSScanner *scanner = [NSScanner scannerWithString:hex];
        (void)[scanner scanHexInt:&colorCode];
    }
    
    return [NSColor colorWithDeviceRed:((colorCode>>16)&0xFF)/255.0 green:((colorCode>>8)&0xFF)/255.0 blue:((colorCode)&0xFF)/255.0 alpha:1.0];
}

- (void)generateImages
{
    SettingsManager *settingsManager = [SettingsManager sharedSettingsManager];
    
    NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:settingsManager.sourceImagePath];
    
    [self saveImage:sourceImage withName:settingsManager.outputImageName andSize:NSMakeSize([settingsManager.outputImageWidth floatValue], [settingsManager.outputImageHeight floatValue])];
}

- (void)calculateSizesPercentsForImage:(NSImage*)image
{
    _percentWidth = image.size.width/100.f;
    _percentHeight = image.size.height/100.f;
}

- (NSImage*)preparedTargetImage:(NSImage*)source
{
    NSString *version = [[SettingsManager sharedSettingsManager] version];
    NSString *buildType = [[SettingsManager sharedSettingsManager] buildType];
    
    NSImage *image = [source copy];
    
    [image lockFocus];
    
    [self calculateSizesPercentsForImage:image];
    
    NSColor *versionTextColor = [ImageProcessingManager colorFromHexadecimalValue:[[SettingsManager sharedSettingsManager] versionTextColor]];
    if (!versionTextColor) {
        versionTextColor = [NSColor whiteColor];
    }
    
    //Draw version
    NSDictionary *versionAttributesDictionary = @{
                                                  NSForegroundColorAttributeName : versionTextColor,
                                                  NSFontAttributeName : [NSFont systemFontOfSize:HEIGHT_PERCENT(10)]
                                                  };
    
    NSRect versionBoundRect = [version boundingRectWithSize:NSMakeSize( WIDTH_PERCENT(100) , HEIGHT_PERCENT(15) ) options:NSStringDrawingDisableScreenFontSubstitution attributes:versionAttributesDictionary];
    versionBoundRect.origin.x = WIDTH_PERCENT(10); // For central position use this code -> (WIDTH_PERCENT(100) - versionBoundRect.size.width)/2;
    versionBoundRect.origin.y = HEIGHT_PERCENT(85);
    
    [version drawWithRect:versionBoundRect options:NSStringDrawingDisableScreenFontSubstitution attributes:versionAttributesDictionary context:nil];
    
    
    //Draw build type
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSCenterTextAlignment;
    
    NSColor *buildTypeTextColor = [ImageProcessingManager colorFromHexadecimalValue:[[SettingsManager sharedSettingsManager] buildTypeTextColor]];
    if (!buildTypeTextColor) {
        buildTypeTextColor = [NSColor redColor];
    }
    
    NSDictionary *buildTypeAttributedDictionary = @{
                                                    NSForegroundColorAttributeName : buildTypeTextColor,
                                                    NSFontAttributeName : [NSFont boldSystemFontOfSize:HEIGHT_PERCENT(20)],
                                                    NSParagraphStyleAttributeName : paragrapStyle
                                                    };
    
    NSRect buildTypeBoundRect = [version boundingRectWithSize:NSMakeSize( WIDTH_PERCENT(100) , HEIGHT_PERCENT(25) ) options:NSStringDrawingDisableScreenFontSubstitution attributes:buildTypeAttributedDictionary];
    buildTypeBoundRect.origin.x = 0;
    buildTypeBoundRect.origin.y = HEIGHT_PERCENT(10);
    buildTypeBoundRect.size.width = WIDTH_PERCENT(100);
    
    [buildType drawWithRect:buildTypeBoundRect options:NSStringDrawingUsesDeviceMetrics attributes:buildTypeAttributedDictionary context:nil];
    
    
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
    NSDictionary *properties = @{@(1.0) : NSImageCompressionFactor};
    imageData = [imageRep representationUsingType:NSPNGFileType properties:properties];
    
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
