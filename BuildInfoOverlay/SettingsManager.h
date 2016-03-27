//
//  SettingsManager.h
//  wadl2objc
//
//  Created by Dmitry on 8/26/13.
//  Copyright (c) 2013 zimCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
#import <AppKit/AppKit.h>

static NSString * const kTextArgumentKey                = @"-text";
static NSString * const kTextColorArgumentKey           = @"-textColor";
static NSString * const kTextSizeArgumentKey            = @"-textSize";
static NSString * const kTextPositionArgumentKey        = @"-textPosition";
static NSString * const kTextAligmentArgumentKey        = @"-textAligment";
static NSString * const kTextXPaddingArgumentKey        = @"-textXPadding";
static NSString * const kTextYPaddingArgumentKey        = @"-textYPadding";

static NSString * const kSourcePathArgumentKey          = @"-sourcePath";
static NSString * const kResultPathArgumentKey          = @"-resultPath";

static NSString * const kResultHeightArgumentKey        = @"-resultHeight";
static NSString * const kResultWidthArgumentKey         = @"-resultWidth";

typedef NS_ENUM(NSUInteger, TextPosition) {
    TextPositionTop,
    TextPositionMiddle,
    TextPositionBottom,
};
@interface SettingsManager : NSObject

@property (nonatomic, strong) NSString *applicationPath;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSColor *textColor;
@property (nonatomic) CGFloat textSize;
@property (nonatomic) TextPosition textPosition;
@property (nonatomic) NSTextAlignment textAligment;
@property (nonatomic) CGFloat textXPadding;
@property (nonatomic) CGFloat textYPadding;

@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSString *resultPath;
@property (nonatomic) CGSize resultSize;

CWL_DECLARE_SINGLETON_FOR_CLASS(SettingsManager);

- (BOOL)setLaunchArguments:(NSArray*)args;

@end
