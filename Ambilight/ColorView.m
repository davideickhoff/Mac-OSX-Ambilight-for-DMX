//
//  ColorView.m
//  Ambilight
//
//  Created by David Eickhoff on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorView.h"

@implementation ColorView
@synthesize backgroundcolor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundcolor set];
    NSRectFill([self bounds]);
}

- (void)changeColor:(NSColor*) aColor
{
    self.backgroundcolor = aColor;
    [self setNeedsDisplay:YES];
}

@end
