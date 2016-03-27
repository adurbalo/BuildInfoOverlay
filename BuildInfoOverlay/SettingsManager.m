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

- (NSError*)errorWithLocalizedDescription:(NSString*)ld
{
    return [[NSError alloc] initWithDomain:@"BuildInfoOverlay" code:-1 userInfo:@{NSLocalizedDescriptionKey : ld?:@""}];
}

-(NSArray<NSString*> *)availableArguments
{
    return @[
             kTextArgumentKey,
             kTextColorArgumentKey,
             kTextSizeArgumentKey,
             kTextPositionArgumentKey,
             kTextAligmentArgumentKey,
             kTextXPaddingArgumentKey,
             kTextYPaddingArgumentKey,
             kSourcePathArgumentKey,
             kResultPathArgumentKey,
             kResultHeightArgumentKey,
             kResultWidthArgumentKey
             ];
}

-(void)showAvailableArguments
{
    NSMutableString *message = [NSMutableString new];
    [[self availableArguments] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [message appendFormat:@"%@\n", obj];
    }];
    NSLog(@"Available arguments:\n%@", message);
}

-(BOOL)validateInputArguments:(NSArray<NSString*> *)args
{
    __block BOOL valid = YES;
    [args enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if (idx%2 == 0) {
            BOOL contain = [[self availableArguments] containsObject:obj];
            if (!contain) {
                NSLog(@"Received unexpected argument: %@", obj);
                [self showAvailableArguments];
                valid = NO;
                *stop = YES;
            }
        }
        
    }];
    return valid;
}

- (NSString*)receiveRequiredArgumentByKey:(NSString*)argumentKey fromArgumentList:(NSArray*)args withError:(NSError**)error
{
    NSUInteger index = [args indexOfObject:argumentKey];
    if (index == NSNotFound){
        if (error) {
            *error = [self errorWithLocalizedDescription:[NSString stringWithFormat:@"Missing required parameter '%@'", argumentKey]];
        }
        return nil;
    }
    NSString *result = args[index + 1];
    return result;
}

- (NSString*)receiveOptionalArgumentByKey:(NSString*)argumentKey fromArgumentList:(NSArray*)args
{
    NSUInteger index = [args indexOfObject:argumentKey];
    if (index == NSNotFound){
        return nil;
    }
    NSString *result = args[index + 1];
    return result;
}

- (BOOL)setLaunchArguments:(NSArray *)arguments
{
    NSMutableArray *args = [NSMutableArray arrayWithArray:arguments];
    
    if (args.count > 0) {
        self.applicationPath = args[0];
        [args removeObjectAtIndex:0];
    }
    
    if (![self validateInputArguments:args]) {
        return NO;
    }
    
    NSError *error = nil;
    
    self.text = [self receiveRequiredArgumentByKey:kTextArgumentKey fromArgumentList:args withError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self showAvailableArguments];
        return NO;
    }
    
    self.textColor = [self parseTextColorArgument:[self receiveOptionalArgumentByKey:kTextColorArgumentKey fromArgumentList:args] withError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self showAvailableArguments];
        return NO;
    }
    
    self.textSize = [[self receiveOptionalArgumentByKey:kTextSizeArgumentKey fromArgumentList:args] floatValue];
    
    self.textPosition = [self parseTextPositionFromArguments:args withError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self showAvailableArguments];
        return NO;
    }
    
    self.textAligment = [self parseTextAlignFromArguments:args withError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self showAvailableArguments];
        return NO;
    }
    
    self.textXPadding = [[self receiveOptionalArgumentByKey:kTextXPaddingArgumentKey fromArgumentList:args] floatValue];
    self.textYPadding = [[self receiveOptionalArgumentByKey:kTextYPaddingArgumentKey fromArgumentList:args] floatValue];
    
    self.sourcePath = [self receiveRequiredArgumentByKey:kSourcePathArgumentKey fromArgumentList:args withError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self showAvailableArguments];
        return NO;
    }
    
    self.resultPath = [self receiveRequiredArgumentByKey:kResultPathArgumentKey fromArgumentList:args withError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self showAvailableArguments];
        return NO;
    }
    
    self.resultSize = [self parseTextSizeFromArguments:args];

    return YES;
}

-(NSColor *)parseTextColorArgument:(NSString*)argument withError:(NSError **)error
{
    if (!argument) {
        return nil;
    }
    
    if ([argument hasPrefix:@"#"]) {
        argument = [argument substringWithRange:NSMakeRange(1, [argument length] - 1)];
    }
    
    unsigned int colorCode = 0;
    
    if (argument) {
        NSScanner *scanner = [NSScanner scannerWithString:argument];
        (void)[scanner scanHexInt:&colorCode];
    }
    
    return [NSColor colorWithDeviceRed:((colorCode>>16)&0xFF)/255.0 green:((colorCode>>8)&0xFF)/255.0 blue:((colorCode)&0xFF)/255.0 alpha:1.0];
}

-(CGSize)parseTextSizeFromArguments:(NSArray*)args
{
    CGFloat height = [[self receiveOptionalArgumentByKey:kResultHeightArgumentKey fromArgumentList:args] floatValue];
    CGFloat width = [[self receiveOptionalArgumentByKey:kResultWidthArgumentKey fromArgumentList:args] floatValue];
    return CGSizeMake(width, height);
}

-(TextPosition)parseTextPositionFromArguments:(NSArray*)args withError:(NSError**)error
{
    NSString *position = [[self receiveOptionalArgumentByKey:kTextPositionArgumentKey fromArgumentList:args] lowercaseString];
    
    if (!position) {
        return TextPositionTop;
    }
    
    NSArray *availableValues = @[@"top", @"middle", @"bottom"];
    if ([availableValues containsObject:position]) {
        return [availableValues indexOfObject:position];
    } else {
        if (error) {
            *error = [self errorWithLocalizedDescription:[NSString stringWithFormat:@"Unexpected parameter for '%@', available values: %@", kTextPositionArgumentKey, availableValues]];
        }
    }
    return TextPositionTop;
}

-(NSTextAlignment)parseTextAlignFromArguments:(NSArray*)args withError:(NSError**)error
{
    NSString *align = [[self receiveOptionalArgumentByKey:kTextAligmentArgumentKey fromArgumentList:args] lowercaseString];
    
    if (!align) {
        return NSTextAlignmentLeft;
    }
    
    NSArray *availableValues = @[@"left", @"right", @"center"];
    if ([availableValues containsObject:align]) {
        return [availableValues indexOfObject:align];
    } else {
        if (error) {
            *error = [self errorWithLocalizedDescription:[NSString stringWithFormat:@"Unexpected parameter for '%@', available values: %@", kTextPositionArgumentKey, availableValues]];
        }
    }
    return NSTextAlignmentLeft;
}

@end
