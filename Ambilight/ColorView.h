//
//  ColorView.h
//  Ambilight
//
//  Created by David Eickhoff on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColorView : NSView {
    NSColor *backgroundColor; 
}

@property (nonatomic, retain) NSColor *backgroundcolor;

- (void)changeColor:(NSColor*) aColor;

@end
