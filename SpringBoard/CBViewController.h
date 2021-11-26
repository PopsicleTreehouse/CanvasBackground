#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@interface CBViewController : UIViewController
@property (class, nonatomic, strong) NSCache *playerCache;
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *thumbnailView;
- (void)recreateCanvasPlayer:(NSNotification *)note;
- (void)togglePlayer:(NSNotification *)note;
@end
@interface CALayer ()
- (void)setSecurityMode:(NSString *)arg1;
@end