//
//  AmbilightAppDelegate.m
//  Ambilight
//
//  Created by David Eickhoff on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AmbilightAppDelegate.h"

// Private properties
@interface AmbilightAppDelegate ()
{
    NSColor *rgbColor;
    NSColor *hsbcolor;
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    CGFloat sat;
    CGFloat bright;
    CGFloat hue;
    
    int scans;
    
    int log[32];
}

@end

@implementation AmbilightAppDelegate

@synthesize window;
@synthesize chooseScreenControl, updateFrequencySlider, resolutionSlider, minBrightSlider, brightFactorTextField, satFactorTextField, colorView;
@synthesize resolutionLabel, minBrightLabel, frequencyLabel;
@synthesize timer, displays, currentScreen;
@synthesize connection, label;
@synthesize resolutionDiv, minBright, brightFac, satFac, updateFrequency;
@synthesize useLog;

- (IBAction)changeScreen:(id)sender 
{
    self.currentScreen = [self.displays objectAtIndex:self.chooseScreenControl.selectedSegment];
}

- (IBAction)changeUpdateFrequency:(id)sender
{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:([self.updateFrequencySlider floatValue]/1000)
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    self.updateFrequency = [self.updateFrequencySlider intValue];
    [self.frequencyLabel.cell setTitle:[NSString stringWithFormat:@"update every %ims", self.updateFrequency]];
}

- (IBAction)changeScanResolution:(id)sender
{
    self.resolutionDiv = [self.resolutionSlider floatValue];
    [self.resolutionLabel.cell setTitle:[NSString stringWithFormat:@"%i^2 scan points", self.resolutionDiv]];
}

- (IBAction)changeMinBrightness:(id)sender
{
    self.minBright = [self.minBrightSlider floatValue]/100;
    [self.minBrightLabel.cell setTitle:[NSString stringWithFormat:@"Min. Brightness (%0.0f%%)", self.minBright*100]];
}

- (IBAction)changeBrightFactor:(id)sender
{
    self.brightFac = [self.brightFactorTextField floatValue];
}

- (IBAction)changeSatFactor:(id)sender
{
    self.satFac = [self.satFactorTextField floatValue];
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    self.updateFrequency = 400;    
    self.minBright = 0.5;
    self.brightFac = 2.7;
    self.satFac = 1.4;
    self.resolutionDiv = 10;
    self.useLog = FALSE;
    
    //log[32] = {0 , 1 , 2 , 2 , 2 , 3 , 3 , 4 , 5 , 6 , 7 , 8 , 10 , 11 , 13 , 16 , 19 , 23 , 27 , 32 , 38 , 45 , 54 , 64 , 76 , 91 , 108 , 128 , 152 , 181 , 215 , 255};

    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.updateFrequency/1000
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];


    CGDirectDisplayID ids[3];
    CGDisplayCount count = 0;    
    CGGetOnlineDisplayList(3, ids, &count);
    
    [self.chooseScreenControl setSegmentCount:count];
    [self.chooseScreenControl setSelected:TRUE forSegment:0];    
    
    self.displays = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        Screen *newScreen = [[Screen alloc] init];
        newScreen.displayId = ids[i];
        newScreen.resolution = CGSizeMake(CGDisplayPixelsWide(ids[i]), CGDisplayPixelsHigh(ids[i]));
        //NSLog(@"resolution: %fx x %f", newScreen.resolution.width, newScreen.resolution.height);
        [self.displays addObject: newScreen];
        [newScreen release];
    }
    
    self.currentScreen = [self.displays objectAtIndex:0];

    
    self.connection = [NetIOConnection instance];
    [self.connection connect];
    
    [self.updateFrequencySlider setIntValue:self.updateFrequency];
    [self.resolutionSlider setIntValue:self.resolutionDiv];
    [self.minBrightSlider setFloatValue:self.minBright*100];
    [self.brightFactorTextField setStringValue:[NSString stringWithFormat:@"%0.3f", self.brightFac]];
    [self.satFactorTextField setStringValue:[NSString stringWithFormat:@"%0.3f", self.satFac]];
    
    
    [self.minBrightLabel.cell setTitle:[NSString stringWithFormat:@"Min. Brightness (%0.0f%%)", self.minBright*100]];
    [self.frequencyLabel.cell setTitle:[NSString stringWithFormat:@"update every %ims", self.updateFrequency]];
    [self.resolutionLabel.cell setTitle:[NSString stringWithFormat:@"%i^2 scan points", self.resolutionDiv]];

    // Insert code here to initialize your application
}


- (void)timerFired:(NSTimer*)aTimer
{
    CGSize frameSize = CGSizeMake(currentScreen.resolution.width / self.resolutionDiv, currentScreen.resolution.height / self.resolutionDiv);

    CGImageRef image = CGDisplayCreateImageForRect(self.currentScreen.displayId, CGRectMake(0, 0, currentScreen.resolution.width, currentScreen.resolution.height));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
        
    red = 0.0;
    green = 0.0;
    blue = 0.0;
    scans = 0;
    
    for (int x=0; x<currentScreen.resolution.width; x=x+frameSize.width) {
        for (int y=0; y<currentScreen.resolution.height; y=y+frameSize.height) {
            rgbColor = [bitmap colorAtX:x y:y];   
            blue += [rgbColor blueComponent];
            red += [rgbColor redComponent];
            green += [rgbColor greenComponent];
            scans++;
        }
    }
    
    red /= scans;
    green /= scans;
    blue /= scans;
    
    hsbcolor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0];
    
    hue = [hsbcolor hueComponent];
    sat = [hsbcolor saturationComponent];
    bright = [hsbcolor brightnessComponent];
    
    
    sat *= self.satFac;
    bright *= self.brightFac;
    
    bright = MAX(self.minBright, bright>0.99 ? 0.99 : bright);
    sat = sat>0.99 ? 0.99 : sat;


    //NSLog(@"hue %0.2f sat %0.2f bright %0.2f", hue, sat, brigth);

    
    rgbColor = [NSColor colorWithDeviceHue:hue saturation:sat brightness:bright alpha:1.0];
    
    [bitmap release];
    
    [colorView changeColor:rgbColor];
    
    if (useLog) {
        [connection sendCommand:[NSString stringWithFormat:@"dmx set 1 0 %i %i %i", log[(int)([rgbColor redComponent]*32)], log[(int)([rgbColor greenComponent]*32)], log[(int)([rgbColor blueComponent]*32)]]];
    } else {
        [connection sendCommand:[NSString stringWithFormat:@"dmx set 1 0 %i %i %i", (int)([rgbColor redComponent]*255), (int)([rgbColor greenComponent]*255), (int)([rgbColor blueComponent]*255)]];
        //[label.cell setTitle:[NSString stringWithFormat:@"R: %i G: %i B: %i", (int)([rgbColor redComponent]*255), (int)([rgbColor greenComponent]*255), (int)([rgbColor blueComponent]*255)]];
    }
}


@end
