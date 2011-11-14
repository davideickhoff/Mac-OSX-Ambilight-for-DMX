//
//  AmbilightAppDelegate.m
//  Ambilight
//
//  Created by David Eickhoff on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AmbilightAppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <time.h> 

#include <artnet/artnet.h>

// Private properties
@interface AmbilightAppDelegate ()
{
    NSColor *rgbColor;
    NSColor *rgbColor_left;
    NSColor *rgbColor_right;

    NSColor *hsbcolor;
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    CGFloat sat;
    CGFloat bright;
    CGFloat hue;

    CGFloat red_right;
    CGFloat green_right;
    CGFloat blue_right;
    
    CGFloat red_left;
    CGFloat green_left;
    CGFloat blue_left;
    
    int scans_left;
    int scans_right;
    int scans;
    
    int log[32];
    NSUserDefaults* defaults;
    
    CGImageRef cgimage;
    
    artnet_node node;
    uint8_t dmx[10];
    
    CGDataProviderRef provider;
}

@property (nonatomic, retain) NSUserDefaults *defaults;

@end

@implementation AmbilightAppDelegate

@synthesize window;
@synthesize chooseScreenControl, updateFrequencySlider, resolutionSlider, minBrightSlider, brightFactorTextField, satFactorTextField, colorView, colorView_left, colorView_right;
@synthesize resolutionLabel, minBrightLabel, frequencyLabel;
@synthesize timer, displays, currentScreen;
@synthesize label;
@synthesize resolutionDiv, minBright, brightFac, satFac, updateFrequency;
@synthesize redSlider, redLabel, redAdjust, greebSlider, greenLabel, greenAdjust, blueSlider, blueLabel, blueAdjust;
@synthesize useLog;
@synthesize defaults;

- (IBAction)adjustOutput:(id)sender 
{
    self.redAdjust = [redSlider intValue];
    self.greenAdjust = [self.greebSlider intValue];
    self.blueAdjust = [self.blueSlider intValue];

    [self.redLabel.cell setTitle:[NSString stringWithFormat:@"Red (%i)", self.redAdjust]];
    [self.greenLabel.cell setTitle:[NSString stringWithFormat:@"Green (%i)", self.greenAdjust]];
    [self.blueLabel.cell setTitle:[NSString stringWithFormat:@"Blue (%i)", self.blueAdjust]];
    [defaults setInteger:self.redAdjust forKey:@"redAdjust"];
    [defaults setInteger:self.greenAdjust forKey:@"greenAdjust"];
    [defaults setInteger:self.blueAdjust forKey:@"blueAdjust"];
    [defaults synchronize];
}

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
    [defaults setInteger:self.updateFrequency forKey:@"updateFrequency"];
    [defaults synchronize];
}

- (IBAction)changeScanResolution:(id)sender
{
    self.resolutionDiv = [self.resolutionSlider floatValue];
    [self.resolutionLabel.cell setTitle:[NSString stringWithFormat:@"%i^2 scan points", self.resolutionDiv]];
    [defaults setInteger:self.resolutionDiv forKey:@"resolutionDiv"];
    [defaults synchronize];
}

- (IBAction)changeMinBrightness:(id)sender
{
    self.minBright = [self.minBrightSlider floatValue]/100;
    [self.minBrightLabel.cell setTitle:[NSString stringWithFormat:@"Min. Brightness (%0.0f%%)", self.minBright*100]];
    [defaults setFloat:self.minBright forKey:@"minBright"];
    [defaults synchronize];
}

- (IBAction)changeBrightFactor:(id)sender
{
    self.brightFac = [self.brightFactorTextField floatValue];
    [defaults setFloat:self.brightFac forKey:@"brightFac"];
    [defaults synchronize];
}

- (IBAction)changeSatFactor:(id)sender
{
    self.satFac = [self.satFactorTextField floatValue];
    [defaults setFloat:self.satFac forKey:@"satFac"];    
    [defaults synchronize];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *appDefaults = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:100], @"updateFrequency",
                                    [NSNumber numberWithFloat:0.6], @"minBright", 
                                    [NSNumber numberWithFloat:1.8], @"brightFac",
                                    [NSNumber numberWithFloat:2.2], @"satFac",
                                    [NSNumber numberWithInt:100], @"resolutionDiv",
                                    [NSNumber numberWithInt:175], @"redAdjust",
                                    [NSNumber numberWithInt:255], @"greenAdjust",
                                    [NSNumber numberWithInt:150], @"blueAdjust",
                                 nil];
    
    [defaults registerDefaults:appDefaults];
    
    self.updateFrequency = (int)[defaults integerForKey:@"updateFrequency"];    
    self.minBright = [defaults floatForKey:@"minBright"];
    self.brightFac = [defaults floatForKey:@"brightFac"];
    self.satFac = [defaults floatForKey:@"satFac"];//2.2;
    self.resolutionDiv = (int)[defaults integerForKey:@"resolutionDiv"];
    self.useLog = FALSE;
    
    self.redAdjust = (int)[defaults integerForKey:@"redAdjust"];
    self.greenAdjust = (int)[defaults integerForKey:@"greenAdjust"];
    self.blueAdjust = (int)[defaults integerForKey:@"blueAdjust"];
    
    //log[32] = {0 , 1 , 2 , 2 , 2 , 3 , 3 , 4 , 5 , 6 , 7 , 8 , 10 , 11 , 13 , 16 , 19 , 23 , 27 , 32 , 38 , 45 , 54 , 64 , 76 , 91 , 108 , 128 , 152 , 181 , 215 , 255};

    
    self.timer = [NSTimer scheduledTimerWithTimeInterval: self.updateFrequency/1000
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];

    
    // Initialize libarnet
    
    
    uint8_t port_addr = 1;
    char *ip_addr = NULL;

    char SHORT_NAME[] = "ArtNet Node";
    char LONG_NAME[] = "ambilight send node";

    // create new artnet node, and set config values
    node = artnet_new(ip_addr, false);
    
    artnet_set_short_name(node, SHORT_NAME);
    artnet_set_long_name(node, LONG_NAME);
    artnet_set_node_type(node, ARTNET_RAW);
    
    artnet_set_port_type(node, 0, ARTNET_ENABLE_INPUT, ARTNET_PORT_DMX);
    artnet_set_port_addr(node, 0, ARTNET_INPUT_PORT, port_addr);
    
    if (artnet_start(node) != ARTNET_EOK) {
        printf("Failed to start: %s\n", artnet_strerror() );
    }
    
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
    
    
    // initialize UI
    
    self.currentScreen = [self.displays objectAtIndex:0];

    [self.updateFrequencySlider setIntValue:self.updateFrequency];
    [self.resolutionSlider setIntValue:self.resolutionDiv];
    [self.minBrightSlider setFloatValue:self.minBright*100];
    [self.brightFactorTextField setStringValue:[NSString stringWithFormat:@"%0.3f", self.brightFac]];
    [self.satFactorTextField setStringValue:[NSString stringWithFormat:@"%0.3f", self.satFac]];

    [self.redSlider setIntValue:redAdjust];
    [self.greebSlider setIntValue:greenAdjust];
    [self.blueSlider setIntValue:blueAdjust];
    
    [self.minBrightLabel.cell setTitle:[NSString stringWithFormat:@"Min. Brightness (%0.0f%%)", self.minBright*100]];
    [self.frequencyLabel.cell setTitle:[NSString stringWithFormat:@"update every %ims", self.updateFrequency]];
    [self.resolutionLabel.cell setTitle:[NSString stringWithFormat:@"%i^2 scan points", self.resolutionDiv]];

    [self adjustOutput:self];
    // Insert code here to initialize your application
}


- (NSColor*)adjustColor:(NSColor*)color
{
    hue = [color hueComponent];
    sat = [color saturationComponent];
    bright = [color brightnessComponent];
    
    sat *= self.satFac;
    bright *= self.brightFac;
        
    bright = MAX(self.minBright, bright>0.99 ? 0.99 : bright);
    sat = sat>0.99 ? 0.99 : sat;

    return [NSColor colorWithDeviceHue:hue saturation:sat brightness:bright alpha:1.0];
}


- (void)timerFired:(NSTimer*)aTimer
{
    CGSize frameSize = CGSizeMake(self.currentScreen.resolution.width*0.004, self.currentScreen.resolution.height*0.004);
            
    red = red_left = red_right = 0.0;
    green = green_left = green_right = 0.0;
    blue = blue_left = blue_right = 0.0;
    scans = scans_left = scans_right = 0;
    
    
    cgimage = CGDisplayCreateImageForRect(self.currentScreen.displayId, CGRectMake(0, 0, currentScreen.resolution.width, currentScreen.resolution.height));
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    //CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
  
    /*
    NSLog(
          @"\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = %s\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n",
          (int)width,
          (int)height,
          CGImageGetColorSpace(cgimage),
          (int)bpp,
          (int)bpc,
          (int)bpr,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask)     ? "YES" : "NO",
          (info & kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Big)    ? "YES" : "NO"
          );
     */
    
    provider = CGImageGetDataProvider(cgimage);
    NSData* data = (id)CGDataProviderCopyData(provider);
    [data autorelease];
    const uint8_t* bytes = [data bytes];
    
    const uint8_t* pixel;
        
    for (size_t y=0; y < height*0.1; y=y+frameSize.height) {
        for (size_t x=0; x < width; x=x+frameSize.width) {
            pixel = &bytes[y * bpr + x * bytes_per_pixel];
            
            blue += (float)pixel[0]/255;
            green += (float)pixel[1]/255;      
            red += (float)pixel[2]/255;

            scans++;  
        }
    }
    
    for (size_t y=0; y < height; y=y+frameSize.height) {
        for (size_t x=0; x < width*0.1; x=x+frameSize.width) {
            pixel = &bytes[y * bpr + x * bytes_per_pixel];

            blue_left += (float)pixel[0]/255;
            green_left += (float)pixel[1]/255;                
            red_left += (float)pixel[2]/255;
            scans_left++;  
        }
    }
    
    for (size_t y=0; y < height; y=y+frameSize.height) {
        for (size_t x=width*0.9; x < width; x=x+frameSize.width) {
            pixel = &bytes[y * bpr + x * bytes_per_pixel];
            
            blue_right += (float)pixel[0]/255;
            green_right += (float)pixel[1]/255;               
            red_right += (float)pixel[2]/255;
            scans_right++;  
        }
    }
    
    CGImageRelease(cgimage);

    
    red /= scans;
    green /= scans;
    blue /= scans;

    red_left /= scans_left;
    green_left /= scans_left;
    blue_left /= scans_left;

    red_right /= scans_right;
    green_right /= scans_right;
    blue_right /= scans_right;
        
    rgbColor = [self adjustColor: [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0]];
    [colorView changeColor:rgbColor];

    rgbColor_left = [self adjustColor: [NSColor colorWithDeviceRed:red_left green:green_left blue:blue_left alpha:1.0]];
    [self.colorView_left changeColor:rgbColor_left];

    rgbColor_right = [self adjustColor: [NSColor colorWithDeviceRed:red_right green:green_right blue:blue_right alpha:1.0]];
    [self.colorView_right changeColor:rgbColor_right];
    
    
    dmx[0] = (int)([rgbColor redComponent]*self.redAdjust);
    dmx[1] = (int)([rgbColor greenComponent]*self.greenAdjust);
    dmx[2] = (int)([rgbColor blueComponent]*self.blueAdjust);
    dmx[3] = (int)([rgbColor_right redComponent]*self.redAdjust);
    dmx[4] = (int)([rgbColor_right greenComponent]*self.greenAdjust);
    dmx[5] = (int)([rgbColor_right blueComponent]*self.blueAdjust);    
    dmx[6] = (int)([rgbColor_left redComponent]*self.redAdjust);
    dmx[7] = (int)([rgbColor_left greenComponent]*self.greenAdjust);
    dmx[8] = (int)([rgbColor_left blueComponent]*self.blueAdjust);
    dmx[9] = 0;
    artnet_send_dmx(node, 0, 9, dmx);
}


@end
