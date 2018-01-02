//
//  DrawImageManager.m
//  BuildInfoOverlay
//
//  Created by Andrey Durbalo on 24.03.14.
//  Copyright (c) 2014 Andrey Durbalo. All rights reserved.
//

#import "ImageProcessingManager.h"
#import "SettingsManager.h"

@interface ImageProcessingManager ()
{
    CGFloat _percentWidth;
    CGFloat _percentHeight;
}

@end

#define WIDTH_PERCENT(x) roundf(_percentWidth * (x))
#define HEIGHT_PERCENT(x) roundf(_percentHeight * (x))
#define FULL_WIDTH WIDTH_PERCENT(100)
#define FULL_HEIGHT HEIGHT_PERCENT(100)

@implementation ImageProcessingManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(ImageProcessingManager);

- (void)generateImage
{
    SettingsManager *settingsManager = [SettingsManager sharedSettingsManager];
    
    NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:settingsManager.sourcePath];
    [self saveGeneratedImageFromSource:sourceImage];
}

- (void)calculateSizesPercentsForImage:(NSImage*)image
{
    _percentWidth = image.size.width/100.f;
    _percentHeight = image.size.height/100.f;
}

- (void)saveGeneratedImageFromSource:(NSImage*)source
{
    CGSize size = CGSizeZero;
    
    if (CGSizeEqualToSize([[SettingsManager sharedSettingsManager] resultSize], CGSizeZero)) {
        size = source.size;
    } else {
        size = [[SettingsManager sharedSettingsManager] resultSize];
    }
    
    NSImage *sourceImage = [self resizeImage:source size:size];
    
    SettingsManager *settings = [SettingsManager sharedSettingsManager];
    if (settings.text.length > 0) {
        sourceImage = [self drawTextInImage:sourceImage];
    }
    
    NSData *imageData = [sourceImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *properties = @{@(1.0) : NSImageCompressionFactor};
    imageData = [imageRep representationUsingType:NSPNGFileType properties:properties];
    
    NSString *resultPath = [[SettingsManager sharedSettingsManager] resultPath];
    
    if(![imageData writeToFile:resultPath atomically:NO]) {
        NSLog(@"Error during writing file to path: %@", resultPath);
    }
}

- (NSImage*)resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    CGImageRef cgRef = [sourceImage CGImageForProposedRect:NULL
                                                   context:nil
                                                     hints:nil];
    
    NSBitmapImageRep *offscreenRep = [[NSBitmapImageRep alloc]
                                      initWithBitmapDataPlanes:NULL
                                      pixelsWide:size.width
                                      pixelsHigh:size.height
                                      bitsPerSample:8
                                      samplesPerPixel:4
                                      hasAlpha:YES
                                      isPlanar:NO
                                      colorSpaceName:NSDeviceRGBColorSpace
                                      bitmapFormat:NSAlphaFirstBitmapFormat
                                      bytesPerRow:0
                                      bitsPerPixel:0];
    
    // set offscreen context
    NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:offscreenRep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:g];
    
    CGContextRef ctx = [g graphicsPort];
    NSRect imgRect = NSMakeRect(0, 0, size.width, size.height);
    CGContextDrawImage(ctx, imgRect, cgRef);
    
    // create an NSImage and add the rep to it
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image addRepresentation:offscreenRep];
    return image;
}

- (NSImage *)drawTextInImage:(NSImage*)sourceImage
{
    NSSize imgSize = [sourceImage size];
    CGImageRef cgRef = [sourceImage CGImageForProposedRect:NULL
                                                   context:nil
                                                     hints:nil];
    
    NSBitmapImageRep *offscreenRep = [[NSBitmapImageRep alloc]
                                      initWithBitmapDataPlanes:NULL
                                      pixelsWide:imgSize.width
                                      pixelsHigh:imgSize.height
                                      bitsPerSample:8
                                      samplesPerPixel:4
                                      hasAlpha:YES
                                      isPlanar:NO
                                      colorSpaceName:NSDeviceRGBColorSpace
                                      bitmapFormat:NSAlphaFirstBitmapFormat
                                      bytesPerRow:0
                                      bitsPerPixel:0];
    
    // set offscreen context
    NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:offscreenRep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:g];
    
    CGContextRef ctx = [g graphicsPort];
    NSRect imgRect = NSMakeRect(0, 0, imgSize.width, imgSize.height);
    CGContextDrawImage(ctx, imgRect, cgRef);
    
    
    [self calculateSizesPercentsForImage:sourceImage];
    
    SettingsManager *settings = [SettingsManager sharedSettingsManager];
    
    NSString *text = settings.text;
    
    NSColor *textColor = settings.textColor;
    if (!textColor) {
        textColor = [NSColor whiteColor];
    }
    
    CGFloat textSize = settings.textSize;
    if (textSize == 0) {
        textSize = HEIGHT_PERCENT(10);
    } else {
        textSize = HEIGHT_PERCENT(textSize);
    }
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = settings.textAligment;
    paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSFont *font = [NSFont systemFontOfSize:textSize];
    
    //Draw version
    NSDictionary *attributesDictionary = @{
                                           NSForegroundColorAttributeName : textColor,
                                           NSFontAttributeName : font,
                                           NSParagraphStyleAttributeName : paragrapStyle
                                           };
    
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading ;
    
    NSRect rect = [text boundingRectWithSize:NSMakeSize( FULL_WIDTH - WIDTH_PERCENT(2*settings.textXPadding) , FULL_HEIGHT - HEIGHT_PERCENT(2*settings.textYPadding) )
                                     options:options
                                  attributes:attributesDictionary];
    
    CGFloat y = 0;
    CGFloat height = CGRectGetHeight(rect);
    
    switch (settings.textPosition) {
        case TextPositionTop:
        {
            y = FULL_HEIGHT - height - HEIGHT_PERCENT(settings.textYPadding);
        }
            break;
        case TextPositionMiddle:
        {
            y = (FULL_HEIGHT - height)/2;
            break;
        }
        case TextPositionBottom:
        {
            y = HEIGHT_PERCENT(settings.textYPadding);
            break;
        }
        default:
            break;
    }
    
    rect.origin.x = WIDTH_PERCENT(settings.textXPadding);
    rect.origin.y = y;
    rect.size.width = FULL_WIDTH - WIDTH_PERCENT(2*settings.textXPadding);
    
    [text drawWithRect:rect
               options:options
            attributes:attributesDictionary
               context:nil];
    
    // create an NSImage and add the rep to it
    NSImage *image = [[NSImage alloc] initWithSize:imgSize];
    [image addRepresentation:offscreenRep];
    return image;
}

@end

