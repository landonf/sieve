//
//  PSMAquaTabStyle.m
//  PSMTabBarControl
//
//  Created by John Pannell on 2/17/06.
//  Copyright 2006 Positive Spin Media. All rights reserved.
//

#import "PSMAquaTabStyle.h"
#import "PSMTabBarCell.h"
#import "PSMTabBarControl.h"

#define kPSMAquaObjectCounterRadius 7.0
#define kPSMAquaCounterMinWidth 20

@implementation PSMAquaTabStyle

- (NSString *)name
{
    return @"Aqua";
}

#pragma mark -
#pragma mark Creation/Destruction

- (id) init
{
    if ( (self = [super init]) ) {
        [self loadImages];
        
        _objectCountStringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Helvetica" size:11.0] toHaveTrait:NSBoldFontMask], NSFontAttributeName,
																					[[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
																					nil, nil];
    }
    return self;
}

- (void) loadImages
{
    // Aqua Tabs Images
    aquaTabBg = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabsBackground"]];
    [aquaTabBg setFlipped:YES];
    
    aquaTabBgDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabsDown"]];
    [aquaTabBgDown setFlipped:YES];
    
    aquaTabBgDownGraphite = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabsDownGraphite"]];
    [aquaTabBgDown setFlipped:YES];
    
    aquaTabBgDownNonKey = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabsDownNonKey"]];
    [aquaTabBgDown setFlipped:YES];
    
    aquaDividerDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabsSeparatorDown"]];
    [aquaDivider setFlipped:NO];
    
    aquaDivider = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabsSeparator"]];
    [aquaDivider setFlipped:NO];
    
    closeButton = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabClose_Front"]];
    closeButtonDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabClose_Front_Pressed"]];
    closeButtonOver = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabClose_Front_Rollover"]];
    
    closeDirtyButton = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabCloseDirty_Front"]];
    closeDirtyButtonDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabCloseDirty_Front_Pressed"]];
    closeDirtyButtonOver = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabCloseDirty_Front_Rollover"]];
        
    addTabButton = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNew"]];
    addTabButtonDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNewPressed"]];
    addTabButtonOver = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNewRollover"]];
}

- (void)dealloc
{
    [aquaTabBg release];
    [aquaTabBgDown release];
    [aquaDividerDown release];
    [aquaDivider release];
    
    [_objectCountStringAttributes release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Control Specifics

- (CGFloat)leftMarginForTabBarControl
{
    return 0.0f;
}

- (CGFloat)rightMarginForTabBarControl
{
    return 24.0f;
}

- (CGFloat)topMarginForTabBarControl
{
	return 0.0f;
}

- (void)setOrientation:(PSMTabBarOrientation)value
{

}

#pragma mark -
#pragma mark Add Tab Button

- (NSImage *)addTabButtonImage
{
    return addTabButton;
}

- (NSImage *)addTabButtonPressedImage
{
    return addTabButtonDown;
}

- (NSImage *)addTabButtonRolloverImage
{
    return addTabButtonOver;
}

#pragma mark -
#pragma mark Cell Specifics

- (NSRect)dragRectForTabCell:(PSMTabBarCell *)cell orientation:(PSMTabBarOrientation)orientation
{
	return [cell frame];
}

- (NSRect)closeButtonRectForTabCell:(PSMTabBarCell *)cell withFrame:(NSRect)cellFrame
{
    if ([cell hasCloseButton] == NO) {
        return NSZeroRect;
    }
    
    NSRect result;
    result.size = [closeButton size];
    result.origin.x = cellFrame.origin.x + MARGIN_X;
    result.origin.y = cellFrame.origin.y + MARGIN_Y + 2.0;
    
    return result;
}

- (NSRect)iconRectForTabCell:(PSMTabBarCell *)cell
{
    NSRect cellFrame = [cell frame];
    
    if ([cell hasIcon] == NO) {
        return NSZeroRect;
    }
    
    NSRect result;
    result.size = NSMakeSize(kPSMTabBarIconWidth, kPSMTabBarIconWidth);
    result.origin.x = cellFrame.origin.x + MARGIN_X;
    result.origin.y = cellFrame.origin.y + MARGIN_Y;
    
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        result.origin.x += [closeButton size].width + kPSMTabBarCellPadding;
    }
    
    return result;
}

- (NSRect)indicatorRectForTabCell:(PSMTabBarCell *)cell
{
    NSRect cellFrame = [cell frame];
    
    if ([[cell indicator] isHidden]) {
        return NSZeroRect;
    }
    
    NSRect result;
    result.size = NSMakeSize(kPSMTabBarIndicatorWidth, kPSMTabBarIndicatorWidth);
    result.origin.x = cellFrame.origin.x + cellFrame.size.width - MARGIN_X - kPSMTabBarIndicatorWidth;
    result.origin.y = cellFrame.origin.y + MARGIN_Y;
    
    return result;
}

- (NSRect)objectCounterRectForTabCell:(PSMTabBarCell *)cell
{
    NSRect cellFrame = [cell frame];
    
    if ([cell count] == 0) {
        return NSZeroRect;
    }
    
    CGFloat countWidth = [[self attributedObjectCountValueForTabCell:cell] size].width;
    countWidth += (2 * kPSMAquaObjectCounterRadius - 6.0);
    if (countWidth < kPSMAquaCounterMinWidth) {
        countWidth = kPSMAquaCounterMinWidth;
    }
    
    NSRect result;
    result.size = NSMakeSize(countWidth, 2 * kPSMAquaObjectCounterRadius); // temp
    result.origin.x = cellFrame.origin.x + cellFrame.size.width - MARGIN_X - result.size.width;
    result.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;
    
    if (![[cell indicator] isHidden]) {
        result.origin.x -= kPSMTabBarIndicatorWidth + kPSMTabBarCellPadding;
    }
    
    return result;
}

- (CGFloat)minimumWidthOfTabCell:(PSMTabBarCell *)cell
{
    CGFloat resultWidth = 0.0;
    
    // left margin
    resultWidth = MARGIN_X;
    
    // close button?
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed])
        resultWidth += [closeButton size].width + kPSMTabBarCellPadding;
    
    // icon?
    if ([cell hasIcon]) {
        resultWidth += kPSMTabBarIconWidth + kPSMTabBarCellPadding;
    }
    
    // the label
    resultWidth += kPSMMinimumTitleWidth;
    
    // object counter?
    if ([cell count] > 0) {
        resultWidth += [self objectCounterRectForTabCell:cell].size.width + kPSMTabBarCellPadding;
    }
    
    // indicator?
    if ([[cell indicator] isHidden] == NO) {
        resultWidth += kPSMTabBarCellPadding + kPSMTabBarIndicatorWidth;
    }
    
    // right margin
    resultWidth += MARGIN_X;
    
    return ceil(resultWidth);
}

- (CGFloat)desiredWidthOfTabCell:(PSMTabBarCell *)cell
{
    CGFloat resultWidth = 0.0;
    
    // left margin
    resultWidth = MARGIN_X;
    
    // close button?
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        resultWidth += [closeButton size].width + kPSMTabBarCellPadding;
    }
    
    // icon?
    if ([cell hasIcon]) {
        resultWidth += kPSMTabBarIconWidth + kPSMTabBarCellPadding;
    }
    
    // the label
    resultWidth += [[cell attributedStringValue] size].width;
    
    // object counter?
    if ([cell count] > 0) {
        resultWidth += [self objectCounterRectForTabCell:cell].size.width + kPSMTabBarCellPadding;
    }
    
    // indicator?
    if ([[cell indicator] isHidden] == NO) {
        resultWidth += kPSMTabBarCellPadding + kPSMTabBarIndicatorWidth;
    }
    
    // right margin
    resultWidth += MARGIN_X;
    
    return ceil(resultWidth);
}

- (CGFloat)tabCellHeight
{
	return kPSMTabBarControlHeight;
}

#pragma mark -
#pragma mark Cell Values

- (NSAttributedString *)attributedObjectCountValueForTabCell:(PSMTabBarCell *)cell
{
    NSString *contents = [NSString stringWithFormat:@"%lu", (unsigned long)[cell count]];
    return [[[NSMutableAttributedString alloc] initWithString:contents attributes:_objectCountStringAttributes] autorelease];
}

- (NSAttributedString *)attributedStringValueForTabCell:(PSMTabBarCell *)cell
{
    NSMutableAttributedString *attrStr;
    NSString * contents = [cell stringValue];
    attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
    NSRange range = NSMakeRange(0, [contents length]);
    
    [attrStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:range];
    
    // Paragraph Style for Truncating Long Text
    static NSMutableParagraphStyle *TruncatingTailParagraphStyle = nil;
    if (!TruncatingTailParagraphStyle) {
        TruncatingTailParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] retain];
        [TruncatingTailParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [TruncatingTailParagraphStyle setAlignment:NSCenterTextAlignment];
    }
    [attrStr addAttribute:NSParagraphStyleAttributeName value:TruncatingTailParagraphStyle range:range];
    
    return attrStr;	
}

#pragma mark -
#pragma mark Drawing

- (void)drawTabCell:(PSMTabBarCell *)cell;
{
    NSRect cellFrame = [cell frame];
    
    // Selected Tab
    if ([cell state] == NSOnState) {
        NSRect aRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height-2.5);
        aRect.size.height -= 0.5;
        
        // proper tint
        NSControlTint currentTint;
        if ([cell controlTint] == NSDefaultControlTint)
            currentTint = [NSColor currentControlTint];
        else
            currentTint = [cell controlTint];
        
        if (![[[cell controlView] window] isKeyWindow]) 
            currentTint = NSClearControlTint;
        
        NSImage *bgImage;
        switch (currentTint) {
            case NSGraphiteControlTint:
                bgImage = aquaTabBgDownGraphite;
                break;
            case NSClearControlTint:
                bgImage = aquaTabBgDownNonKey;
                break;
            case NSBlueControlTint:
            default:
                bgImage = aquaTabBgDown;
                break;
        }
        
        [bgImage drawInRect:cellFrame fromRect:NSMakeRect(0.0, 0.0, 1.0, 22.0) operation:NSCompositeSourceOver fraction:1.0];
        [aquaDivider compositeToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 1.0, cellFrame.origin.y + cellFrame.size.height) operation:NSCompositeSourceOver];
        
        aRect.size.height+=0.5;
        
    } else { // Unselected Tab
        
        NSRect aRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);
        aRect.origin.y += 0.5;
        aRect.origin.x += 1.5;
        aRect.size.width -= 1;
        
        aRect.origin.x -= 1;
        aRect.size.width += 1;
        
        // Rollover
        if ([cell isHighlighted]) {
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
            NSRectFillUsingOperation(aRect, NSCompositeSourceAtop);
        }
        
        [aquaDivider compositeToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 1.0, cellFrame.origin.y + cellFrame.size.height) operation:NSCompositeSourceOver];
    }
    
    [self drawInteriorWithTabCell:cell inView:[cell controlView]];
}

- (void)drawBackgroundInRect:(NSRect)rect
{
	if (rect.size.height <= 22.0) {
		//Draw for our whole bounds; it'll be automatically clipped to fit the appropriate drawing area
		rect = [tabBar bounds];

		[aquaTabBg drawInRect:rect fromRect:NSMakeRect(0.0, 0.0, 1.0, 22.0) operation:NSCompositeSourceOver fraction:1.0];
	}
}

- (void)drawTabBar:(PSMTabBarControl *)bar inRect:(NSRect)rect
{
	if (tabBar != bar) {
		tabBar = bar;
	}

	[self drawBackgroundInRect:rect];
    
    // no tab view == not connected
    if (![bar tabView]) {
        NSRect labelRect = rect;
        labelRect.size.height -= 4.0;
        labelRect.origin.y += 4.0;
        NSMutableAttributedString *attrStr;
        NSString *contents = @"PSMTabBarControl";
        attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
        NSRange range = NSMakeRange(0, [contents length]);
        [attrStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:range];
        NSMutableParagraphStyle *centeredParagraphStyle = nil;
        if (!centeredParagraphStyle) {
            centeredParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] retain];
            [centeredParagraphStyle setAlignment:NSCenterTextAlignment];
        }
        [attrStr addAttribute:NSParagraphStyleAttributeName value:centeredParagraphStyle range:range];
        [attrStr drawInRect:labelRect];
        return;
    }
    
    // Draw cells
    NSEnumerator *e = [[bar cells] objectEnumerator];
    PSMTabBarCell *cell;
    while ( (cell = [e nextObject]) ) {
        if ([bar isAnimating] || (![cell isInOverflowMenu] && NSIntersectsRect([cell frame], rect))) {
            [cell drawWithFrame:[cell frame] inView:bar];
        }
    }
}   	

- (void)drawInteriorWithTabCell:(PSMTabBarCell *)cell inView:(NSView*)controlView
{
    NSRect cellFrame = [cell frame];
    CGFloat labelPosition = cellFrame.origin.x + MARGIN_X;
    
    // close button
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        NSSize closeButtonSize = NSZeroSize;
        NSRect closeButtonRect = [cell closeButtonRectForFrame:cellFrame];
        NSImage *closeButtonImage = [self closeButtonImageForCell: cell];
        
        closeButtonSize = [closeButtonImage size];
        
        if ([controlView isFlipped]) {
            closeButtonRect.origin.y += closeButtonRect.size.height;
        }
        
        [closeButtonImage compositeToPoint:closeButtonRect.origin operation:NSCompositeSourceOver fraction:1.0];
        
        // scoot label over
        labelPosition += closeButtonSize.width + kPSMTabBarCellPadding;
    }
    
    // icon
    if ([cell hasIcon]) {
        NSRect iconRect = [self iconRectForTabCell:cell];
        NSImage *icon = [[[cell representedObject] identifier] icon];
        if ([controlView isFlipped]) {
            iconRect.origin.y += iconRect.size.height;
        }
        
        // center in available space (in case icon image is smaller than kPSMTabBarIconWidth)
        if ([icon size].width < kPSMTabBarIconWidth) {
            iconRect.origin.x += (kPSMTabBarIconWidth - [icon size].width) / 2.0;
        }
        
        if ([icon size].height < kPSMTabBarIconWidth) {
            iconRect.origin.y -= (kPSMTabBarIconWidth - [icon size].height) / 2.0;
        }
        
        [icon compositeToPoint:iconRect.origin operation:NSCompositeSourceOver fraction:1.0];
        
        // scoot label over
        labelPosition += iconRect.size.width + kPSMTabBarCellPadding;
    }
    
    // label rect
    NSRect labelRect;
    labelRect.origin.x = labelPosition;
    labelRect.size.width = cellFrame.size.width - (labelRect.origin.x - cellFrame.origin.x) - kPSMTabBarCellPadding;
    labelRect.size.height = cellFrame.size.height;
    labelRect.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;
    
    if (![[cell indicator] isHidden]) {
        labelRect.size.width -= (kPSMTabBarIndicatorWidth + kPSMTabBarCellPadding);
    }
    
    // object counter
    if ([cell count] > 0) {
        [[cell countColor] ?: [NSColor colorWithCalibratedWhite:0.3 alpha:0.45] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        NSRect myRect = [self objectCounterRectForTabCell:cell];
        [path moveToPoint:NSMakePoint(myRect.origin.x + kPSMAquaObjectCounterRadius, myRect.origin.y)];
        [path lineToPoint:NSMakePoint(myRect.origin.x + myRect.size.width - kPSMAquaObjectCounterRadius, myRect.origin.y)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(myRect.origin.x + myRect.size.width - kPSMAquaObjectCounterRadius, myRect.origin.y + kPSMAquaObjectCounterRadius) radius:kPSMAquaObjectCounterRadius startAngle:270.0 endAngle:90.0];
        [path lineToPoint:NSMakePoint(myRect.origin.x + kPSMAquaObjectCounterRadius, myRect.origin.y + myRect.size.height)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(myRect.origin.x + kPSMAquaObjectCounterRadius, myRect.origin.y + kPSMAquaObjectCounterRadius) radius:kPSMAquaObjectCounterRadius startAngle:90.0 endAngle:270.0];
        [path fill];
        
        // draw attributed string centered in area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectCountValueForTabCell:cell];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = myRect.origin.x + ((myRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = myRect.origin.y + ((myRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];
        
        labelRect.size.width -= myRect.size.width + kPSMTabBarCellPadding;
    }
    
    // Draw Label
    [[cell attributedStringValue] drawInRect:labelRect];
}

#pragma mark -
#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeObject:aquaTabBg forKey:@"aquaTabBg"];
        [aCoder encodeObject:aquaTabBgDown forKey:@"aquaTabBgDown"];
        [aCoder encodeObject:aquaTabBgDownGraphite forKey:@"aquaTabBgDownGraphite"];
        [aCoder encodeObject:aquaTabBgDownNonKey forKey:@"aquaTabBgDownNonKey"];
        [aCoder encodeObject:aquaDividerDown forKey:@"aquaDividerDown"];
        [aCoder encodeObject:aquaDivider forKey:@"aquaDivider"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder allowsKeyedCoding]) {
            aquaTabBg = [[aDecoder decodeObjectForKey:@"aquaTabBg"] retain];
            aquaTabBgDown = [[aDecoder decodeObjectForKey:@"aquaTabBgDown"] retain];
            aquaTabBgDownGraphite = [[aDecoder decodeObjectForKey:@"aquaTabBgDownGraphite"] retain];
            aquaTabBgDownNonKey = [[aDecoder decodeObjectForKey:@"aquaTabBgDownNonKey"] retain];
            aquaDividerDown = [[aDecoder decodeObjectForKey:@"aquaDividerDown"] retain];
            aquaDivider = [[aDecoder decodeObjectForKey:@"aquaDivider"] retain];
        }
    }
    return self;
}

@end
