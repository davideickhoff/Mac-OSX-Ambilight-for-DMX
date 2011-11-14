//
//  AmbilightAppDelegate.h
//  Ambilight
//
//  Created by David Eickhoff on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Screen.h"
#import "ColorView.h"

@interface AmbilightAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSSegmentedControl* chooseScreenControl;
    NSSlider *updateFrequencySlider;
    NSTextField *frequencyLabel;
    
    NSSlider *resolutionSlider;
    NSTextField *resolutionLabel;
    
    NSSlider *minBrightSlider;
    NSTextField *minBrightLabel;

    NSTextField *brightFactorTextField;
    NSTextField *satFactorTextField;
    ColorView *colorView;
    ColorView *colorView_right;
    ColorView *colorView_left;
    
    NSSlider *redSlider;
    NSSlider *greebSlider;
    NSSlider *blueSlider;
    NSTextField *redLabel;
    NSTextField *greenLabel;
    NSTextField *blueLabel;

    NSTimer* timer;    
    NSMutableArray *displays;
    Screen *currentScreen;
    
    int resolutionDiv;
    int updateFrequency;
    CGFloat minBright;
    CGFloat brightFac;
    CGFloat satFac;
    int redAdjust;
    int greenAdjust;
    int blueAdjust;
    
    BOOL useLog;
    
    NSTextField* label;
    
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) IBOutlet NSSegmentedControl* chooseScreenControl;
@property (nonatomic, retain) IBOutlet NSSlider *updateFrequencySlider;
@property (nonatomic, retain) IBOutlet NSTextField *frequencyLabel;

@property (nonatomic, retain) IBOutlet NSSlider *resolutionSlider;
@property (nonatomic, retain) IBOutlet NSTextField *resolutionLabel;

@property (nonatomic, retain) IBOutlet NSSlider *minBrightSlider;
@property (nonatomic, retain) IBOutlet NSTextField *minBrightLabel;

@property (nonatomic, retain) IBOutlet NSTextField *brightFactorTextField;
@property (nonatomic, retain) IBOutlet NSTextField *satFactorTextField;
@property (nonatomic, retain) IBOutlet ColorView *colorView;
@property (nonatomic, retain) IBOutlet ColorView *colorView_right;
@property (nonatomic, retain) IBOutlet ColorView *colorView_left;


@property (nonatomic, retain) IBOutlet NSSlider *redSlider;
@property (nonatomic, retain) IBOutlet NSSlider *greebSlider;
@property (nonatomic, retain) IBOutlet NSSlider *blueSlider;
@property (nonatomic, retain) IBOutlet NSTextField *redLabel;
@property (nonatomic, retain) IBOutlet NSTextField *greenLabel;
@property (nonatomic, retain) IBOutlet NSTextField *blueLabel;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSMutableArray* displays;
@property (nonatomic, retain) Screen *currentScreen;

@property (assign) int updateFrequency;
@property (assign) int resolutionDiv;
@property (assign) CGFloat minBright;
@property (assign) CGFloat brightFac;
@property (assign) CGFloat satFac;
@property (assign) int redAdjust;
@property (assign) int greenAdjust;
@property (assign) int blueAdjust;

@property (assign) BOOL useLog;

@property (nonatomic, retain) IBOutlet NSTextField* label;
    
- (IBAction)changeScreen:(id)sender;
- (IBAction)changeUpdateFrequency:(id)sender;
- (IBAction)changeScanResolution:(id)sender;
- (IBAction)changeMinBrightness:(id)sender;
- (IBAction)changeBrightFactor:(id)sender;
- (IBAction)adjustOutput:(id)sender;

@end
