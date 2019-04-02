#import <Foundation/Foundation.h>
#import "ColorPickerViewController.h"

@protocol CustomStatusItemDelegate
- (void)toggleShowWindowFromPoint:(NSPoint)point forceAnchoring:(BOOL)forceAnchoring;
- (void)anderToggleWindow;
@end

@interface CustomStatusItem : NSView

@property (assign) NSPoint mouseLocation;
@property (retain) id <CustomStatusItemDelegate> delegate;
@property (retain) NSImage *menuBarImage;
@property (assign) NSRect imageRect;
@property (assign) NSRect colorRect;
@property (assign) BOOL showPreview;
/* ander: trying to display hex value in menu bar */
@property (assign) NSString *colorName;
@property (assign) NSTextView *colorNameTextView;
/* */


- (NSPoint)getAnchorPoint;

@end
