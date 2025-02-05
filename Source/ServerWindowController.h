/* Copyright (c) 1010 Sven Weidauer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
 * to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the 
 * Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
 * THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */


#import <Cocoa/Cocoa.h>

#import "SieveClient.h"

@class PSMTabBarControl;
@class SieveScriptViewController;

@interface ServerWindowController : NSWindowController < NSTabViewDelegate, NSWindowDelegate, SieveClientDelegate > {
    IBOutlet PSMTabBarControl *tabBar;
    IBOutlet NSTabView *tabView;
    IBOutlet NSTableView *scriptListView;
    IBOutlet NSArrayController *scriptsArrayController;
    
    NSURL *baseURL;
    SieveClient *client;
    NSMutableArray *scripts;
    NSString *activeScript;
}

@property (readwrite, retain) SieveClient *client;
@property (readwrite, copy) NSURL *baseURL;
@property (readwrite, copy) NSString *activeScript;

- (id) initWithURL: (NSURL *) url;

- (void) openURL: (NSURL *) url;

- (void) setScripts: (NSArray *) newScripts;

- (unsigned)countOfScripts;
- (id)objectInScriptsAtIndex:(unsigned)theIndex;

- (IBAction) newDocument: (id) sender;
- (IBAction) activateScript: (id) sender;
- (IBAction) renameScript: (id) sender;
- (IBAction) delete: (id) sender;

- (void) windowShouldCloseWithBlock: (void (^)( BOOL shouldClose )) shouldCloseBlock;

@end
