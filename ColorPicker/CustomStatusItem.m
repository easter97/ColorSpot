#import "CustomStatusItem.h"
#import "ColorPicker.h"

@implementation CustomStatusItem

@synthesize mouseLocation;
@synthesize delegate;
@synthesize menuBarImage;
@synthesize imageRect;
@synthesize colorRect;
@synthesize showPreview;
/* ander */
@synthesize colorNameTextView;

#define kPadding 3.0

extern bool appIsPaused = false;
extern bool needToShowWindowOnCPVC = false;

- (id)initWithFrame:(NSRect)frameRect {
//    frameRect.size.width = 2; //ander trying this to fix text in status bar
    self = [super initWithFrame:frameRect];
    
    if (self) {
        showPreview = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsShowMenuBarPreview];
    }
    [self displayColorNameTextField];
    
    return self;
}

/* ander */
- (void)displayColorNameTextField {
    self.colorName = @"";
    colorNameTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(30, 3, 75, 10)];
    [colorNameTextView setSelectable:false];
    [colorNameTextView setFont:[NSFont systemFontOfSize:14.0]];
    [colorNameTextView setString:@""];
    //NSLog(@"font: %@", colorNameTextView.font);
    colorNameTextView.backgroundColor = [NSColor clearColor];
    [colorNameTextView setTextColor:[NSColor whiteColor]];
//    [colorNameTextField setStringValue:@"My Label"];
    
    [self addSubview: colorNameTextView];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (!menuBarImage) {
        self.menuBarImage = [NSImage imageNamed:@"ColorPicker_menubar.png"];
        imageRect = NSMakeRect(0, 3, menuBarImage.size.width, menuBarImage.size.height);
        colorRect = NSMakeRect(menuBarImage.size.width + kPadding, 6, 10, 10);
    }
    [menuBarImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];

    
    if (!appIsPaused) {
        if (mouseLocation.x) {
            [colorNameTextView setString:[ColorPickerViewController colorNameFromColor:[ColorPicker colorAtLocation:mouseLocation]]];
            if (showPreview) {
                NSColor *currentColor = [ColorPicker colorAtLocation:mouseLocation];
                
                [currentColor set];
                NSRectFill(colorRect);
    //            [self setFrameSize:NSMakeSize(menuBarImage.size.width + kPadding + colorRect.size.width + kPadding, self.frame.size.height)];
            } else {
    //            [self setFrameSize:NSMakeSize(menuBarImage.size.width + kPadding, self.frame.size.height)];
            }
        }
    }
}

#pragma mark toggleWindow

- (NSPoint)getAnchorPoint {
	NSRect frame = [[self window] frame];
	NSRect screen = [[NSScreen mainScreen] frame];
	NSPoint point = NSMakePoint(NSMidX(frame), screen.size.height - [[NSStatusBar systemStatusBar] thickness]);

	return point;
}

- (void)toggleShowWindow {
    if ([(NSObject *)delegate respondsToSelector:@selector(toggleShowWindowFromPoint:forceAnchoring:)]) {
        [delegate toggleShowWindowFromPoint:[self getAnchorPoint] forceAnchoring:NO];
    }
}

#pragma mark Events

// The icon was clicked, we toggle the window
- (void)mouseDown:(NSEvent *)event {
    /* ander: did this because I didn't want the app to move to foreground when icon was clicked */
    if ([(NSObject *)delegate respondsToSelector:@selector(anderToggleWindow)])
    {
        if (appIsPaused) {
            appIsPaused = false;
        }
        [delegate anderToggleWindow];
    }
    /* original */
//    [self toggleShowWindow];
}

/* ander */
- (void)rightMouseDown:(NSEvent *)event {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu insertItemWithTitle:@"Quit" action:@selector(quitApp) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Toggle" action:@selector(toggleApp) keyEquivalent:@"" atIndex:1];
    
    [NSMenu popUpContextMenu:theMenu withEvent:event forView:self];
}

- (void)quitApp {
    [NSApp terminate:self];
}
     
- (void)toggleApp {
    appIsPaused = !appIsPaused;
    [colorNameTextView setString:@""];
    if (!appIsPaused) {
        needToShowWindowOnCPVC = true;
    }
}

@end
