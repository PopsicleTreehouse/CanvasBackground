#import "CBViewController.h"

@interface CBViewController (private)
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *thumbnailView;
- (void)recreateCanvasPlayer:(NSNotification *)note;
- (void)togglePlayer:(NSNotification *)note;
- (void)resizePlayer;
@end

@implementation CBViewController
- (void)togglePlayer:(NSNotification *)note {
	BOOL isPlaying = [[[note userInfo] objectForKey:@"isPlaying"] boolValue];
	if(isPlaying) [self.canvasPlayer play];
	else [self.canvasPlayer pause];
}
/*
  Called whenever Spotify changes the current song
  This just updates the canvas based on the userInfo
  containing the thumbnail and canvas URL
*/
- (void)recreateCanvasPlayer:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
	NSURL *currentVideoURL = [NSURL URLWithString:[userInfo objectForKey:@"currentURL"]];
    [self.thumbnailView setHidden:NO];
    if(currentVideoURL) {
        [self.canvasPlayerLayer setOpacity:1];
        AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:(NSURL *) currentVideoURL];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[(AVURLAsset *)currentItem.asset URL] options:nil];
        AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        UIImage *firstFrame = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
        [self.thumbnailView setImage:firstFrame];
        [self.canvasPlayer play];
        self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
	}
	else {
        NSData *currentImageData = [userInfo objectForKey:@"artwork"];
        [self.thumbnailView setImage:[UIImage imageWithData:currentImageData]];
		[self.canvasPlayer removeAllItems];
	}
}
/*
  We need to do this to prevent thumbnailView
  from appearing under the canvas, wasting power
*/
- (void)observeValueForKeyPath:(NSString*)path ofObject:(id)object change:(NSDictionary*)change context:(void*) context {
    if([self.canvasPlayerLayer isReadyForDisplay]) {
        [self.thumbnailView setHidden:YES];
    }
}
/*
  Called whenever screen changes rotation
  we need to do this since ios doesn't
  automatically resize UIViews
*/
- (void)resizePlayer {
    [super viewDidLayoutSubviews];
    [self.view setFrame:self.view.superview.bounds];
    [self.thumbnailView setFrame:self.view.superview.bounds];
    [self.canvasPlayerLayer setFrame:[[self view] bounds]];
}
- (void)viewDidLoad {
	[super viewDidLoad];
	self.thumbnailView = [[UIImageView alloc] initWithFrame:[[self view] frame]];
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
    [self.view setClipsToBounds:YES];
    [self.view setContentMode:UIViewContentModeScaleAspectFill];
	[self.thumbnailView setContentMode:UIViewContentModeScaleAspectFill];
	[self.thumbnailView setHidden:YES];
	[self.canvasPlayer setVolume:0];
	[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.canvasPlayerLayer setFrame:[[self view] bounds]];
	[self.canvasPlayerLayer setHidden:YES];
    [self.canvasPlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
	[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[[self view] layer] setSecurityMode:@"secure"];
	[[self view] insertSubview:self.thumbnailView atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizePlayer) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePlayer:) name:@"togglePlayer" object:@"com.spotify.client"];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.canvasPlayerLayer setHidden:NO];
	[self.canvasPlayer play];
}
@end