#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Hook UIWindow to constrain Stheno windows within screen bounds
%hook UIWindow

// Helper function to check if window is a Stheno window
static BOOL IsSthenoWindow(UIWindow *window) {
    NSString *className = NSStringFromClass([window class]);
    return [className containsString:@"Stheno"] || 
           [className hasSuffix:@"SthenoWindow"] ||
           [className hasSuffix:@"Window"];
}

// Hook setFrame: to constrain within screen bounds
- (void)setFrame:(CGRect)frame {
    if (IsSthenoWindow(self)) {
        UIScreen *screen = self.screen ?: [UIScreen mainScreen];
        CGRect screenBounds = screen.bounds;
        CGFloat screenWidth = screenBounds.size.width;
        CGFloat screenHeight = screenBounds.size.height;
        
        // Constrain the frame within screen bounds
        CGFloat minX = CGRectGetMinX(frame);
        CGFloat minY = CGRectGetMinY(frame);
        CGFloat maxX = CGRectGetMaxX(frame);
        CGFloat maxY = CGRectGetMaxY(frame);
        
        // Clamp minX to be >= 0
        if (minX < 0) {
            frame.origin.x = 0;
        }
        // Clamp minY to be >= 0
        if (minY < 0) {
            frame.origin.y = 0;
        }
        // Clamp maxX to be <= screenWidth
        if (maxX > screenWidth) {
            frame.origin.x = screenWidth - frame.size.width;
        }
        // Clamp maxY to be <= screenHeight
        if (maxY > screenHeight) {
            frame.origin.y = screenHeight - frame.size.height;
        }
        
        // Handle edge case where window is larger than screen
        if (frame.size.width > screenWidth) {
            frame.size.width = screenWidth;
        }
        if (frame.size.height > screenHeight) {
            frame.size.height = screenHeight;
        }
        
        // Final safety clamp
        frame.origin.x = MAX(0, MIN(frame.origin.x, screenWidth - frame.size.width));
        frame.origin.y = MAX(0, MIN(frame.origin.y, screenHeight - frame.size.height));
    }
    
    %orig(frame);
}

// Hook setCenter: to constrain center within screen bounds
- (void)setCenter:(CGPoint)center {
    if (IsSthenoWindow(self)) {
        UIScreen *screen = self.screen ?: [UIScreen mainScreen];
        CGRect screenBounds = screen.bounds;
        CGFloat screenWidth = screenBounds.size.width;
        CGFloat screenHeight = screenBounds.size.height;
        
        CGFloat halfWidth = self.bounds.size.width / 2.0;
        CGFloat halfHeight = self.bounds.size.height / 2.0;
        
        // Constrain center so window stays within screen
        center.x = MAX(halfWidth, MIN(center.x, screenWidth - halfWidth));
        center.y = MAX(halfHeight, MIN(center.y, screenHeight - halfHeight));
    }
    
    %orig(center);
}

%end

// Constructor
%ctor {
    NSLog(@"[SthenoBoundary] Tweak loaded - constraining Stheno windows to screen bounds");
}
