#import "CBViewController.h"

@implementation CBViewController
// -(UIImage *)getArtworkImage {
//     NSBundle *mediaRemoteBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MediaRemote.framework"];
//     [mediaRemoteBundle load];
//     UIImage *__block currentArtwork = nil;
//     MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
// 		if (information) {
// 			NSDictionary* dictionary = (__bridge NSDictionary *)information;
// 			currentArtwork = [UIImage imageWithData:[dictionary objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
//             NSLog(@"canvasBackground currentArtwork: %@", currentArtwork);
//         }
//     });
//     return currentArtwork;
// }
- (void)togglePlayer:(NSNotification *)note {
	BOOL isPlaying = [[[note userInfo] objectForKey:@"isPlaying"] boolValue];
	if(isPlaying) [self.canvasPlayer play];
	else [self.canvasPlayer pause];
	self.shouldPlayCanvas = isPlaying;
}
- (void)recreateCanvasPlayer:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
	NSURL *currentVideoURL = [NSURL URLWithString: [userInfo objectForKey:@"currentURL"]];
    if(currentVideoURL) {     
        [self.thumbnailView setHidden:NO];
		AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:(NSURL *) currentVideoURL];
		AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[(AVURLAsset *)currentItem.asset URL] options:nil];
		AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
		UIImage *firstFrame = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
		[self.thumbnailView setImage:firstFrame];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
		if(self.isVisible) [self.canvasPlayer play];
        [self.canvasPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
        [self.thumbnailView setHidden:NO];
	}
	else {
        NSData *currentImageData = [userInfo objectForKey:@"artwork"];
        [self.thumbnailView setImage:[UIImage imageWithData:currentImageData]];
		[self.thumbnailView setHidden:NO];
		[self.canvasPlayer removeAllItems];
	}
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.canvasPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.canvasPlayer.status == AVPlayerStatusReadyToPlay) {
            [self.thumbnailView setHidden:YES];
        }
    }
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
	[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[[self view] layer] setSecurityMode:@"secure"];
	[[self view] insertSubview:self.thumbnailView atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePlayer:) name:@"togglePlayer" object:@"com.spotify.client"];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view setFrame:self.view.superview.bounds];
    [self.thumbnailView setFrame:self.view.superview.bounds];
    [self.canvasPlayerLayer setFrame:[[self view] bounds]];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.isVisible = YES;
	[self.canvasPlayerLayer setHidden:NO];
	SBMediaController *controller = [objc_getClass("SBMediaController") sharedInstance];
	if(![controller isPaused] && ![controller isPlaying]) [self.canvasPlayer removeAllItems];
	if(self.shouldPlayCanvas) [self.canvasPlayer play];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.isVisible = NO;
    [self.thumbnailView setHidden:YES];
	[self.canvasPlayerLayer setHidden:YES];
	[self.canvasPlayer pause];
}
@end