#import "CustomStatusItem.h"
#import "ColorPicker.h"

@implementation CustomStatusItem

@synthesize mouseLocation;
@synthesize delegate;
@synthesize menuBarImage;
@synthesize imageRect;
@synthesize colorRect;
@synthesize showPreview;

#define kPadding 3.0

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        showPreview = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsShowMenuBarPreview];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    /* Ander: we don't need the menu bar so I commented it out - actually we do */
    if (!menuBarImage) {
        self.menuBarImage = [NSImage imageNamed:@"ColorPicker_menubar.png"];
        imageRect = NSMakeRect(0, 3, menuBarImage.size.width, menuBarImage.size.height);
        colorRect = NSMakeRect(menuBarImage.size.width + kPadding, 6, 10, 10);
    }
    /* in case I need to disable it again */
    
    if (mouseLocation.x) 
    {
        [menuBarImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
        
        if (showPreview) {
            NSColor *currentColor = [ColorPicker colorAtLocation:mouseLocation];
            
            [currentColor set];
            NSRectFill(colorRect);
            [self setFrameSize:NSMakeSize(menuBarImage.size.width + kPadding + colorRect.size.width + kPadding, self.frame.size.height)];
        } else
        {
            [self setFrameSize:NSMakeSize(menuBarImage.size.width + kPadding, self.frame.size.height)];
        }
    }
}

#pragma mark toggleWindow

- (NSPoint)getAnchorPoint
{	
	NSRect frame = [[self window] frame];
	NSRect screen = [[NSScreen mainScreen] frame];
	NSPoint point = NSMakePoint(NSMidX(frame), screen.size.height - [[NSStatusBar systemStatusBar] thickness]);
    
	return point;
}

- (void)toggleShowWindow
{
    if ([(NSObject *)delegate respondsToSelector:@selector(toggleShowWindowFromPoint:forceAnchoring:)]) 
    {
        [delegate toggleShowWindowFromPoint:[self getAnchorPoint] forceAnchoring:NO];
    }
}

#pragma mark Events

// The icon was clicked, we toggle the window

- (void)mouseDown:(NSEvent *)event {
    /* ander: did this because I didn't want the app to move to foreground when icon was clicked */
    if ([(NSObject *)delegate respondsToSelector:@selector(anderToggleWindow)])
    {
        [delegate anderToggleWindow];
    }
    /* original */
//    [self toggleShowWindow];
}

@end
