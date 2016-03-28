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

- (NSImage*)drawTextInImage:(NSImage*)source
{
    NSImage *image = [source copy];
    
    [image lockFocus];
    
    [self calculateSizesPercentsForImage:image];
    
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

    [image unlockFocus];
    
    return image;
}

@end
