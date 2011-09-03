//
//  Screen.h
//  Ambilight
//
//  Created by David Eickhoff on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Screen : NSObject {
    CGDirectDisplayID displayId;
    CGSize resolution;
}

@property (assign) CGDirectDisplayID displayId;
@property (assign) CGSize resolution;

@end
