//
//  DrawImageManager.h
//  BuildInfoOverlay
//
//  Created by Andrey Durbalo on 24.03.14.
//  Copyright (c) 2014 Andrey Durbalo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface ImageProcessingManager : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(ImageProcessingManager);

- (void)generateImages;

@end
