//
//  ColorPickerViewController.m
//  ColorPicker
//
//  Created by Oscar Del Ben on 8/22/11.
//  Copyright 2011 DibiStore. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "ColorPicker.h"
#import "ColorPickerPreview.h"
#import "ColorHistoryView.h"
#import "ColorsHistoryController.h"
#import "AppController.h"
#import "NSColorFormatter.h"
#import "SRRecorderCell.h"

@implementation ColorPickerViewController
@synthesize appController;
@synthesize mouseLocation;
@synthesize colorPickerPreview;
@synthesize rgbText;
@synthesize hexText;
@synthesize hueText;
@synthesize saturationText;
@synthesize brightnessText;
/* ander */
@synthesize colorText;
@synthesize colorPreview;
@synthesize shortcutLabel;
@synthesize updateColorsHistory;
@synthesize colorHistoryView1, colorHistoryView2, colorHistoryView3, colorHistoryView4, colorHistoryView5;
@synthesize x, y;

/* ander */
NSString *colorNameFromColor(NSColor *color) {
    NSString *colorName = @"";
    int hue = (int)([color hueComponent] * 360);
    
    
    if (0 < hue && hue <= 14) {
        colorName = @"Red";
    } else if (15 <= hue && hue <= 45) {
        colorName = @"Orange";
    } else if (46 <= hue && hue <= 70) {
        colorName = @"Yellow";
    } else if (71 <= hue && hue <= 79) {
        colorName = @"Lime";
    } else if (80 <= hue && hue <= 163) {
        colorName = @"Green";
    } else if (164 <= hue && hue <= 193) {
        colorName = @"Cyan";
    } else if (194 <= hue && hue <= 240) {
        colorName = @"Blue";
    } else if (241 <= hue && hue <= 260) {
        colorName = @"Indigo";
    } else if (261 <= hue && hue <= 270) {
        colorName = @"Violet";
    } else if (271 <= hue && hue <= 291) {
        colorName = @"Purple";
    } else if (292 <= hue && hue <= 327) {
        colorName = @"Magenta";
    } else if (328 <= hue && hue <= 344) {
        colorName = @"Rose";
    } else if (345 <= hue && hue <= 359) {
        colorName = @"Red";
    } else {
//        NSLog(@"red value: %f", [color redComponent]);
        float redValue = [color redComponent] * 256;
        if (redValue < 22) {
            colorName = @"Black";
        } else if (redValue >= 22 && redValue < 241) {
            colorName = @"Gray";
        } else {
            colorName = @"White";
        }
    }
    return colorName;
}

NSImage *swatchWithColor(NSColor *color) {
    NSSize size;
    size = NSMakeSize(50, 50);
    
    
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [color drawSwatchInRect:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    return image;
}
/* ander again */
- (void)deliverNotification {
    NSColor *currentColor = [ColorPicker colorAtLocation:mouseLocation];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [NSString stringWithFormat:@"Color: %@", colorNameFromColor(currentColor)];
    notification.informativeText = [currentColor colorToRGBRepresentation];
    notification.contentImage = swatchWithColor(currentColor);
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.updateColorsHistory = YES;
    }
    
    return self;
}

- (void)awakeFromNib
{
    colorHistoryView1.viewController = self;
    colorHistoryView2.viewController = self;
    colorHistoryView3.viewController = self;
    colorHistoryView4.viewController = self;
    colorHistoryView5.viewController = self;
}

#pragma mark Utils

- (void)updateHistoryView
{
    if (!updateColorsHistory)
        return;
    
    colorHistoryView1.color = [ColorsHistoryController colorAtIndex:0];
    colorHistoryView2.color = [ColorsHistoryController colorAtIndex:1];
    colorHistoryView3.color = [ColorsHistoryController colorAtIndex:2];
    colorHistoryView4.color = [ColorsHistoryController colorAtIndex:3];
    colorHistoryView5.color = [ColorsHistoryController colorAtIndex:4];
    
    [colorHistoryView1 setNeedsDisplay:YES];
    [colorHistoryView2 setNeedsDisplay:YES];
    [colorHistoryView3 setNeedsDisplay:YES];
    [colorHistoryView4 setNeedsDisplay:YES];
    [colorHistoryView5 setNeedsDisplay:YES];
    
    updateColorsHistory = NO;
}

#pragma mark -

- (void)updateView
{
    if (!mouseLocation.x)
        return;
    
    // picker view
    
    NSImage *pickerImage = [ColorPicker imageForLocation:mouseLocation];
    
    colorPickerPreview.preview = pickerImage;
    [colorPickerPreview setNeedsDisplay:YES];
    
    // colors
    
    NSColor *currentColor = [ColorPicker colorAtLocation:mouseLocation];
  
    colorPreview.color = currentColor;
    [colorPreview setNeedsDisplay:YES];
    
    [rgbText setStringValue:[currentColor colorToRGBRepresentation]];
    [hexText setStringValue:[currentColor colorToHEXRepresentation]];

    [hueText setStringValue:[currentColor colorToHueRepresentation]];
    [saturationText setStringValue:[currentColor colorToSaturationRepresentation]];
    [brightnessText setStringValue:[currentColor colorToBrightnessRepresentation]];
    
    /* ander */
    /* reference this site https://www.color-blindness.com/color-name-hue/ */
    [colorText setStringValue:colorNameFromColor(currentColor)];
    
    [x setStringValue:[NSString stringWithFormat:@"%.f", mouseLocation.x]];
    [y setStringValue:[NSString stringWithFormat:@"%.f", mouseLocation.y]];
    
    [self updateHistoryView];
}

- (void)captureColor:(BOOL)saveToHistory
{
    NSColor *currentColor = [ColorPicker colorAtLocation:mouseLocation];

    [appController copyColorToPasteboard:currentColor];
    
    if (saveToHistory) {
        [ColorsHistoryController push:currentColor];
        
        updateColorsHistory = YES;
        [self updateView];
    }
}

- (IBAction)hide:(id)sender {
    /* ander: modified code to work with the command + arrow hotkeys*/
    [self.appController.window orderOut:self];
    /* original code below */
//    [appController toggleShowWindow];
}

- (void)updateShortcutText {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    float code = [userDefaults integerForKey:kUserDefaultsKeyCode];
    float modifier = [[userDefaults valueForKey:kUserDefaultsModifierKeys] longValue];
    
	NSString *newLabel = nil;
	if (code != -1) {
		newLabel = [NSString stringWithFormat: @"Press %@%@ to copy color", SRStringForCocoaModifierFlags(modifier), SRStringForKeyCode(code)];
	}
	else {
		newLabel = @"No shortcut defined";
	}
    [shortcutLabel setStringValue:newLabel];
}

@end
