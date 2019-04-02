
#define kUserDefaultsFrameOriginX @"kUserDefaultsFrameOriginX"
#define kUserDefaultsFrameOriginY @"kUserDefaultsFrameOriginY"

#define kUserDefaultsKeyStartAtLogin @"kUserDefaultsKeyStartAtLogin"
#define kUserDefaultsKeyTimesRun @"kUserDefaultsKeyTimesRun"
#define kUserDefaultsColorsHistory @"kUserDefaultsColorsHistory"

#define kUserDefaultsDefaultFormat @"kUserDefaultsDefaultFormat"
#define kUserDefaultsShowMenuBarPreview @"kUserDefaultsShowMenuBarPreview"

#define kUserDefaultsKeyCode @"kUserDefaultsKeyCode"
#define kUserDefaultsModifierKeys @"kUserDefaultsModifierKeys"

/*
 The MIT License (MIT)
 
 Copyright (c) 2011 Oscar Del Ben
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

typedef enum {
    kFormatHEX,
    kFormatRGB,
    kFormatHexWithoutHash,
    kFormatCMYK,
    kFormatUIColor,
    kFormatNSColor,
    kFormatMonoTouch
} kFormats;

#define kNumberOfColorsHistory 5

#define kAlertTitleStartupItem @"Run at Login?"                 
#define kAlertTextStartupItem @"Click \"Yes\" if you would like to run Color Picker Pro when you login."

#define kInstructions @"Color Picker Pro makes it easy to get color information from the screen.\n\nTo capture a color, simply press cmd + shift + p (you can change the shortcut in the preferences). You can see a preview of the color directly on the window or in the menu bar at any time.\n\nWhen you copy a color, it will get copied to your clipboard and added to the colors history. To copy a color back from the history simply click on it.\n\n You can hide and show the main interface by clicking on its menu bar icon, or by pressing ESC when the application is active. There are many preferences that you can tweak to customize the behavior of Color Picker."
