#import "AppController.h"
#import "ColorPickerViewController.h"
#import "RSLoginItems.h"
#import "DDHotKeyCenter.h"
#import "NSColorFormatter.h"
#import "PreferencesController.h"
#import "HelpController.h"
#import "EventsResponderView.h"

@implementation AppController

@synthesize window;
@synthesize statusItem;
@synthesize statusItemView;
@synthesize view;
@synthesize loginItems;
@synthesize viewController;
@synthesize preferencesController;
@synthesize helpController;
@synthesize updateTimer;
@synthesize updateMouseLocation;
@synthesize mouseLocation;

- (void)awakeFromNib
{
    self.loginItems = [[RSLoginItems alloc] init];
    
    // Count app runs
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	int timesRun = (int)[defs integerForKey:kUserDefaultsKeyTimesRun];
	if (!timesRun)
		timesRun = 1;
	else
		timesRun++;
	[defs setInteger:timesRun forKey:kUserDefaultsKeyTimesRun]; 	
	[defs synchronize];
	NSLog(@"This app has been run %d times", timesRun);
    
    // setup window
    self.viewController = [[ColorPickerViewController alloc] initWithNibName:@"ColorPickerView" bundle:nil];
    viewController.appController = self;
    self.view = viewController.view;
    
    self.window = [[CustomWindow alloc] initWithView:self.view];
    [window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    
    // setup status bar
    
    float width = 120; // will change programmatically
    float height = [[NSStatusBar systemStatusBar] thickness];
    NSRect statusItemFrame = NSMakeRect(0, 0, width, height);
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItemView = [[CustomStatusItem alloc] initWithFrame:statusItemFrame];
//    self.statusItem.title = @"123456789123456789";
    [statusItemView setDelegate:self];
    
    [statusItem setView:self.statusItemView];
    
    updateMouseLocation = YES;
    
    [self updateViews];
    
    // Show window
    if (timesRun == 1)
    {
		NSBeginAlertSheet(kAlertTitleStartupItem,
						  @"No", nil, @"Yes",
						  nil, self,                   
						  @selector(runOnLogin:returnCode:contextInfo:),
						  nil, nil,                 
						  kAlertTextStartupItem,
						  nil);		
	}	
	else 
    {
		[self toggleShowWindowFromPoint:[statusItemView getAnchorPoint] forceAnchoring:YES];
	}
    
    [self registerHotKey];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateViews) userInfo:nil repeats:YES];
    
    // When the user presses an arrow key, we stop tracking the mouse location. To turn it on again they just need to move the mouse
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^ (NSEvent *event){
        updateMouseLocation = YES;
    }];
    
    
    // Add events handler
    EventsResponderView *eventsView = [[EventsResponderView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    eventsView.appController = self;
    [self.view addSubview:eventsView];
    [self.window makeFirstResponder:eventsView];
}

- (void)anderToggleWindow {
    if ([self.window isVisible]) {
        [self.window orderOut:self];
    } else {
        [self.window makeKeyAndOrderFront:self];
        //            [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)toggleShowWindowFromPoint:(NSPoint)point forceAnchoring:(BOOL)forceAnchoring
{
    [self.window setAttachPoint:point forceAnchoring:forceAnchoring];
    [self.window toggleVisibility];
    
    // Force window to front 
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)toggleShowWindow
{
    [self toggleShowWindowFromPoint:[statusItemView getAnchorPoint] forceAnchoring:NO];
}

- (void)updateViews
{
    if (updateMouseLocation) {
        mouseLocation = [NSEvent mouseLocation];
        NSScreen *principalScreen = [[NSScreen screens] objectAtIndex:0];
        mouseLocation = NSMakePoint(mouseLocation.x, principalScreen.frame.size.height - mouseLocation.y);
    }

    statusItemView.mouseLocation = mouseLocation;
    viewController.mouseLocation = mouseLocation;
    
    [statusItemView setNeedsDisplay:YES];
    [viewController updateView];
}

#pragma mark run at login

- (void)runOnLogin:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (NSAlertOtherReturn == returnCode)	{
		NSLog(@"User did set login item");
		[self.loginItems addAppAsLoginItem];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyStartAtLogin];
	}
	[self toggleShowWindow];
}

#pragma mark HotKeys

- (void)registerHotKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
    DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	DDHotKeyTask task = ^(NSEvent *hkEvent) {
		[viewController captureColor:YES];
        [window setAlphaValue:1.0]; // force show window
        NSLog(@"AM::Hotkey shift+command+p");
	};

	if (![c registerHotKeyWithKeyCode:[userDefaults integerForKey:kUserDefaultsKeyCode] 
                        modifierFlags:[[userDefaults valueForKey:kUserDefaultsModifierKeys] longValue] 
                                 task:task]) {
		NSLog(@"Unable to register hotkey");
	} else {
		NSLog(@"Registered hotkey");
	}
    
    /* Ander: added code for alt/option + spacebar hotkey to allow the user to get the color of any pixel and anytime */
    DDHotKeyTask displayNotificationTask = ^(NSEvent *hkEvent) {
        [viewController deliverNotification];
        NSLog(@"AM::Hotkey displayNotificationTask");
    };
    if (![c registerHotKeyWithKeyCode:0x31
                        modifierFlags:(NSEventModifierFlagOption)
                                 task:displayNotificationTask]) {
        NSLog(@"Unable to register hotkey");
    } else {
        NSLog(@"Registered hotkey");
    }
    
    /* Ander: added code for command + up arrow hotkey so user can use precision controls wherever */
    DDHotKeyTask commandUpTask = ^(NSEvent *hkEvent) {
        if (![self.window isVisible]) {
            [self.window makeKeyAndOrderFront:self];
        }
        [self moveUp];
        NSLog(@"AM::Hotkey commandUpTask");
    };
    if (![c registerHotKeyWithKeyCode:0x7E
                        modifierFlags:(NSEventModifierFlagCommand)
                                 task:commandUpTask]) {
        NSLog(@"Unable to register hotkey");
    } else {
        NSLog(@"Registered hotkey");
    }
    
    /* Ander: added code for command + down arrow hotkey so user can use precision controls wherever */
    DDHotKeyTask commandDownTask = ^(NSEvent *hkEvent) {
        if (![self.window isVisible]) {
            [self.window makeKeyAndOrderFront:self];
        }
        [self moveDown];
        NSLog(@"AM::Hotkey commandDownTask");
    };
    if (![c registerHotKeyWithKeyCode:0x7D
                        modifierFlags:(NSEventModifierFlagCommand)
                                 task:commandDownTask]) {
        NSLog(@"Unable to register hotkey");
    } else {
        NSLog(@"Registered hotkey");
    }
    
    /* Ander: added code for command + left arrow hotkey so user can use precision controls wherever */
    DDHotKeyTask commandLeftTask = ^(NSEvent *hkEvent) {
        if (![self.window isVisible]) {
            [self.window makeKeyAndOrderFront:self];
        }
        [self moveLeft];
        NSLog(@"AM::Hotkey commandLeftTask");
    };
    if (![c registerHotKeyWithKeyCode:0x7B
                        modifierFlags:(NSEventModifierFlagCommand)
                                 task:commandLeftTask]) {
        NSLog(@"Unable to register hotkey");
    } else {
        NSLog(@"Registered hotkey");
    }
    
    /* Ander: added code for command + right arrow hotkey so user can use precision controls wherever */
    DDHotKeyTask commandRightTask = ^(NSEvent *hkEvent) {
        if (![self.window isVisible]) {
            [self.window makeKeyAndOrderFront:self];
        }
        [self moveRight];
        NSLog(@"AM::Hotkey commandUpTask");
    };
    if (![c registerHotKeyWithKeyCode:0x7C
                        modifierFlags:(NSEventModifierFlagCommand)
                                 task:commandRightTask]) {
        NSLog(@"Unable to register hotkey");
    } else {
        NSLog(@"Registered hotkey");
    }
    
    /* Ander: added code for control + tilde arrow hotkey to toggle the UI */
    DDHotKeyTask controlTildeTask = ^(NSEvent *hkEvent) {
        if ([self.window isVisible]) {
            [self.window orderOut:self];
        } else {
            [self.window makeKeyAndOrderFront:self];
            //            [NSApp activateIgnoringOtherApps:YES];
        }
        NSLog(@"AM::Hotkey controlTildeTask");
    };
    if (![c registerHotKeyWithKeyCode:0x32
                        modifierFlags:(NSEventModifierFlagControl)
                                 task:controlTildeTask]) {
        NSLog(@"Unable to register hotkey");
    } else {
        NSLog(@"Registered hotkey");
    }

    // https://developer.apple.com/documentation/appkit/nseventmodifierflags/nseventmodifierflagshift?language=objc
    // http://www.letworyinteractive.com/blendercode/d1/def/GHOST__SystemCocoa_8mm.html
    
    [viewController updateShortcutText];
}

- (void)unregisterHotKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	[c unregisterHotKeyWithKeyCode:[userDefaults integerForKey:kUserDefaultsKeyCode]
                     modifierFlags:[[userDefaults valueForKey:kUserDefaultsModifierKeys] longValue]];
	NSLog(@"Unregistered hotkey");
}

#pragma mark -

- (void)copyColorToPasteboard:(NSColor *)color
{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    
    long format = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultsDefaultFormat];
    
    switch (format) {
        case kFormatHEX:
            [pasteBoard setString:[color colorToHEXRepresentation] forType:NSStringPboardType];
            break;
        case kFormatHexWithoutHash:
            [pasteBoard setString:[color colorToHEXWithoutHashRepresentation] forType:NSStringPboardType];
            break;
        case kFormatCMYK:
			[pasteBoard setString:[color colorToCMYKRepresentation] forType:NSStringPboardType];
            break;
        case kFormatRGB:
            [pasteBoard setString:[color colorToRGBRepresentation] forType:NSStringPboardType];
            break;
        case kFormatUIColor:
            [pasteBoard setString:[color colorToUIColorRepresentation] forType:NSStringPboardType];
            break;
        case kFormatNSColor:
            [pasteBoard setString:[color colorToNSColorRepresentation] forType:NSStringPboardType];
            break;
        case kFormatMonoTouch:
            [pasteBoard setString:[color colorToMonoTouchRepresentation] forType:NSStringPboardType];
            break;
        default:
            [pasteBoard setString:[color colorToRGBRepresentation] forType:NSStringPboardType];
            break;
	}
}

- (IBAction)showPreferences:(id)sender
{
    if (!preferencesController) {
        self.preferencesController = [[PreferencesController alloc] init];
        preferencesController.loginItems = self.loginItems;
        preferencesController.statusItemView = self.statusItemView;
        preferencesController.appController = self;
    }
    
    [preferencesController showWindow:self];
}

- (IBAction)showHelp:(id)sender
{
    if (!helpController) {
        self.helpController = [[HelpController alloc] init];
    }
    [helpController showWindow:self];
}

- (void)moveLeft
{
    updateMouseLocation = NO;
    mouseLocation.x -= 1;
}

- (void)moveRight
{
    updateMouseLocation = NO;
    mouseLocation.x += 1;
}

- (void)moveDown
{
    updateMouseLocation = NO;
    mouseLocation.y += 1;
}

- (void)moveUp
{
    updateMouseLocation = NO;
    mouseLocation.y -= 1;
}

@end
