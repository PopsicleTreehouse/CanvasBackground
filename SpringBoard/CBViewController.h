#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <objc/runtime.h>

@interface SBMediaController : NSObject
+ (id)sharedInstance;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end
@interface CBViewController : UIViewController
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL shouldPlayCanvas;
@property (nonatomic, assign) BOOL shouldRemoveImage;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)togglePlayer:(NSNotification *)note;
@end
@interface CALayer ()
-(void)setSecurityMode:(NSString *)arg1;
@end