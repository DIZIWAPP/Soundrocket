//
//  PlayerViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKFontAwesome.h>
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>
#import <MarqueeLabel.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CommentsTableViewController.h"
#import "PlayerViewController.h"
#import"UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "CredentialStore.h"
#import "SoundtraceClient.h"
#import <FAKIonIcons.h>
#import <SZTextView.h>
#import <SVProgressHUD.h>
#import "SRStylesheet.h"

@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *showVolumeFaderButton;
@property (weak, nonatomic) IBOutlet UIButton *showCommentsButton;
@property(nonatomic,strong) AVPlayer * soundPlayer;
@property (nonatomic,strong) AVAsset * currentAsset;
@property (nonatomic,strong) AVPlayerItem * streamingItem;
@property (nonatomic,strong) NSMutableArray * currentCommentViews;
@property (nonatomic,strong) NSMutableArray * currentComments;
@property (nonatomic) BOOL runTimeDetection;
@property (nonatomic,strong) CredentialStore * store;
@property (nonatomic,strong) UIView * scrollBar;
@property (nonatomic,strong) UIView * bufferingSzone;
@property (weak, nonatomic) IBOutlet UIView *contentViewofVisualEffectView;
@property (nonatomic) BOOL isLoopActive;
@property (nonatomic,strong)UIView * currentCommentView;
@property NSInteger currentCommentIndex;
@property (nonatomic,assign) BOOL liked;
@property (nonatomic,assign) BOOL  commentingViewActive;
@property (nonatomic,strong) UIView * commentingView;
@property (nonatomic,strong) UIImage * artworkImage;
// Commenting
@property(nonatomic,strong)UIView * commentPlacerView;
@property(nonatomic,strong)UIView * commentingCanvas;
@property(nonatomic,strong)UIView * volumeControlView;
@property(nonatomic,assign)BOOL volumeViewActive;
@property(nonatomic,strong)UIView * miscView;
@end

@implementation PlayerViewController

// Singleton Player Instance for Music Playback
+ (instancetype)sharedPlayer {
    static PlayerViewController *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _sharedPlayer = [sb instantiateViewControllerWithIdentifier:@"Now Playing"];
    });
    return _sharedPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.volumeViewActive = NO;
    [self setupVolumeView];
    self.artworkImage = [UIImage imageNamed:@"music"];
    //[self setupVolumeView];
    [self setDoneButton];
    [self setNextButton];
    [self clearNavigationBar];
    self.isLoopActive = false;
    self.runTimeDetection = true;
    self.liked = false;
    self.nextCommentButton.tintColor = [SRStylesheet mainColor];
    self.lastCommentButton.tintColor = [SRStylesheet mainColor];
    self.trackIDLabel.textColor = [SRStylesheet mainColor];
    // Setting up Scrollbar
    UIView *scrollbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, self.waveformImageView.frame.size.height)];
    scrollbar.backgroundColor = [SRStylesheet mainColor];
    self.scrollBar = scrollbar;
    self.scrollBar.layer.zPosition = -1;
    [self.waveformImageView addSubview:self.scrollBar];
    
    self.soundPlayer = [[AVPlayer alloc]init];
    [self.soundPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    self.currentCommentViews = [[NSMutableArray alloc]init];
    self.currentComments = [[NSMutableArray alloc]init];
    self.store = [[CredentialStore alloc]init];

    

    
    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pannedWaveform:)];
    [self.waveformImageView addGestureRecognizer:panRecognizer];
    
    UIPanGestureRecognizer * panCommentsRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pannedComments:)];
    panCommentsRecognizer.maximumNumberOfTouches = 1;
    panCommentsRecognizer.minimumNumberOfTouches = 1;
    [self.commentsView addGestureRecognizer:panCommentsRecognizer];
    
    FAKIonIcons *starIcon = [FAKIonIcons chatboxIconWithSize:20];
    self.commentIconLabel.attributedText = [starIcon attributedString];
    
    [self.nextCommentButton setAttributedTitle:[[FAKIonIcons ios7ArrowRightIconWithSize:20]attributedString] forState:UIControlStateNormal];
    [self.lastCommentButton setAttributedTitle:[[FAKIonIcons ios7ArrowLeftIconWithSize:20]attributedString] forState:UIControlStateNormal];
    
    self.nextTrackButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.lastTrackButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setupCommentingFunction];
    [self createCommentingView];
    
    FAKIonIcons *volume = [FAKIonIcons volumeHighIconWithSize:20];
    FAKIonIcons *comment = [FAKIonIcons chatboxIconWithSize:20];
    [self.showCommentsButton setAttributedTitle:[comment attributedString] forState:UIControlStateNormal];
    [self.showVolumeFaderButton setAttributedTitle:[volume attributedString] forState:UIControlStateNormal];
    
    [self setupSharing];
    [self setupDownloading];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}
-(void)setupSharing {
    FAKIonIcons *cogIcon = [FAKIonIcons ios7UploadOutlineIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    UIBarButtonItem *sharingButton =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(sharingButtonTapped:)];
    
    NSMutableArray * items = [self.navigationItem.rightBarButtonItems mutableCopy];
    [items addObject:sharingButton];
    self.navigationItem.rightBarButtonItems = items;
}

-(void)setNextButton {
    FAKIonIcons *cogIcon = [FAKIonIcons ios7MoreOutlineIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showNext)];
}
-(void)setDoneButton {
    FAKIonIcons *cogIcon = [FAKIonIcons ios7ArrowDownIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(closePlayerButtonPressed:)];
}

-(void)setupDownloading {
    /*FAKIonIcons * cogIcon = [FAKIonIcons arrowDownCIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    
    UIBarButtonItem * downloadIcon = [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showNext)];
    NSMutableArray * items = [self.navigationItem.leftBarButtonItems mutableCopy];
    [items addObject:downloadIcon];
    self.navigationItem.leftBarButtonItems = items;*/
}

-(void)sharingButtonTapped:(UIBarButtonItem*)button {
    NSString *string = [NSString stringWithFormat:@"%@ by %@ on #SoundCloud via #Soundrocket",self.currentTrack.title,self.currentTrack.user.username];
    NSURL *URL = [NSURL URLWithString:self.currentTrack.permalink_url];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string,URL]
                                      applicationActivities:nil];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         // ...
                     }];
}

-(void)setupVolumeView{
    self.volumeControlView.alpha = 0.0;
    self.volumeControlView.layer.zPosition = 2000;
    self.volumeControlView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height+50, self.view.frame.size.width, 60)];
    self.volumeControlView.backgroundColor = [SRStylesheet darkGrayColor];
    
    // Setting up the Button
    UIButton * closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 60)];
    FAKIonIcons * closeIcon = [FAKIonIcons closeRoundIconWithSize:20];
    [closeButton setAttributedTitle:[closeIcon attributedString] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(hideVolumeView) forControlEvents:UIControlEventTouchUpInside];
    closeButton.titleLabel.textColor = [UIColor whiteColor];
    [self.volumeControlView addSubview:closeButton];
    
    
    MPVolumeView *myVolumeView =
    [[MPVolumeView alloc] initWithFrame: CGRectMake(60,20, self.volumeControlView.frame.size.width-70, self.volumeControlView.frame.size.height)];
    [self.volumeControlView addSubview:myVolumeView];
    [self.contentViewofVisualEffectView addSubview: self.volumeControlView];
}

-(void)createCommentingView {
    // show Comment View bla bla
    self.commentingView = [[UIView alloc]initWithFrame:CGRectMake(0, -(self.coverImageView.frame.origin.y + self.coverImageView.frame.size.height), self.view.frame.size.width, self.coverImageView.frame.size.height + self.coverImageView.frame.origin.y-(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))];
    UIVisualEffectView * visualEffectView = [[UIVisualEffectView alloc]initWithEffect:[[UIBlurEffect alloc]init]];
    [visualEffectView setFrame:CGRectMake(0, 0, self.commentingView.frame.size.width, self.commentingView.frame.size.height -50)];
    [self.commentingView addSubview:visualEffectView];
    SZTextView * commentingTextView = [[SZTextView alloc]initWithFrame:CGRectMake(0, 0, self.commentingView.frame.size.width, self.commentingView.frame.size.height -50)];
    commentingTextView.textColor = [SRStylesheet darkGrayColor];
    commentingTextView.placeholderTextColor = [SRStylesheet lightGrayColor];
    commentingTextView.placeholder = @"Enter a comment here";
    commentingTextView.backgroundColor = [UIColor clearColor];
    self.commentingView.backgroundColor = [UIColor clearColor];
    commentingTextView.tag = 1;
    [self.commentingView addSubview:commentingTextView];
    
    // Submit Button
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.commentingView.frame.size.height-50, self.commentingView.frame.size.width/2,50)];
    [cancelButton setBackgroundColor:[SRStylesheet mainColor]];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(hideCommentingView) forControlEvents:UIControlEventTouchDown];
    cancelButton.layer.zPosition = 5000;
    cancelButton.enabled = YES;
    [self.commentingView addSubview:cancelButton];
    
    // Cancel Button
    UIButton * submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.commentingView.frame.size.width/2, self.commentingView.frame.size.height-50, self.commentingView.frame.size.width/2, 50)];
    [submitButton setBackgroundColor:[UIColor colorWithRed:0.133 green:0.867 blue:0.600 alpha:1.000]];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.layer.zPosition = 5000;
    submitButton.enabled = YES;
    [self.commentingView addSubview:submitButton];
    [self.view addSubview:self.commentingView];
}

// Submit the fucking comment
-(void)submitComment:(id)sender{
    
    [SVProgressHUD showWithStatus:@"Commenting"];
    float placePosition = self.commentPlacerView.frame.origin.x; // Position auf dem Bildschirm
    float width = self.waveformImageView.frame.size.width;
    float timeStampOfTrack = [self.currentTrack.duration floatValue];
    
    float timeStamp = (placePosition/width) * timeStampOfTrack;
    int intTimeStamp = (int)timeStamp;
    
    NSNumber * postionTimeStamp = [NSNumber numberWithInt:intTimeStamp];
    UITextView * textView = (UITextView*)[self.commentingView viewWithTag:1];
    NSString * comment = textView.text;
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    NSMutableDictionary * subparams = [[NSMutableDictionary alloc]init];
    [subparams setObject:comment forKey:@"body"];
    [subparams setObject:postionTimeStamp.stringValue forKey:@"timestamp"];
    [parameters setObject:subparams forKey:@"comment"];

    [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
    [[SoundtraceClient sharedClient] POST:[NSString stringWithFormat:@"/tracks/%@/comments",self.currentTrack.id] parameters:parameters
     success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         [[UIApplication sharedApplication]endIgnoringInteractionEvents];
         [self hideCommentingView];
         SZTextView * textlabel = (SZTextView*)[self.commentingView viewWithTag:1];
         textlabel.text = @"";
         [SVProgressHUD showSuccessWithStatus:@"Successfully commented"];
         [self setUpComments:self.currentTrack];
     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [[UIApplication sharedApplication]endIgnoringInteractionEvents];
         [SVProgressHUD showErrorWithStatus:@"Something went wrong please try again"];
     }];
}
-(void)setupCommentingFunction {
    self.commentingViewActive = NO;
    UILongPressGestureRecognizer * pressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTappedCommentArea:)];
    [pressRecognizer setMinimumPressDuration:0.5];
    [self.commentsView addGestureRecognizer:pressRecognizer];
}

-(void)longTappedCommentArea:(UILongPressGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(!self.commentingViewActive){
            self.commentingViewActive = true;
            
            //Show Canvas
            if(!self.commentingCanvas){
                
                self.commentingCanvas = [[UIView alloc]initWithFrame:self.commentsView.frame];
                self.commentingCanvas.backgroundColor = [SRStylesheet darkGrayColor];
                UIPanGestureRecognizer * panrecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(commentingCanvasPanned:)];
                panrecognizer.maximumNumberOfTouches = 1;
                panrecognizer.minimumNumberOfTouches = 1;
                [self.commentingCanvas addGestureRecognizer:panrecognizer];
                [self.view  addSubview:self.commentingCanvas];
            }
            
            
            NSUInteger heightOfCommentingView = self.commentsView.frame.size.height;
            CGPoint pt = [recognizer locationOfTouch:0 inView:recognizer.view];
            
            self.commentPlacerView = [[UIView alloc]initWithFrame:CGRectMake(pt.x, 0, 1, heightOfCommentingView)];
            self.commentPlacerView.backgroundColor = [SRStylesheet mainColor];
            
            [self.commentingCanvas addSubview:self.commentPlacerView];
            
            [self showCommentingView];

        }
    }
}

-(void)commentingCanvasPanned:(UIPanGestureRecognizer*)recognizer{
    if ([recognizer numberOfTouches] > 0) {
        NSUInteger heightOfCommentingView = self.commentsView.frame.size.height;
        CGPoint pt = [recognizer locationOfTouch:0 inView:recognizer.view];
        self.commentPlacerView.frame = CGRectMake(pt.x, 0, 1, heightOfCommentingView);
    }
}

-(void)showCommentingView {

    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    
    self.commentingView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.coverImageView.frame.origin.y + self.coverImageView.frame.size.height);
    self.commentingCanvas.hidden = NO;
    [UIView commitAnimations];
}

-(void)hideCommentingView {
    self.commentingViewActive = NO;
    [self.commentPlacerView removeFromSuperview];
    self.commentPlacerView = nil;
    [[self.commentingView viewWithTag:1]resignFirstResponder];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    self.commentingView.frame = CGRectMake(0, -self.commentingView.frame.size.height, self.view.frame.size.width, 150);
    self.commentingCanvas.hidden = YES;
    [UIView commitAnimations];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    //NSLog(@"Item did finish playing");
    // Will be called when AVPlayer finishes playing playerItem
    if (self.isLoopActive) {
        [self playNextTrack];
    } else if(NO) { // if autoplay is on
        // shuffle
    } else {
        [self playNextTrack];
    }
}



-(void)clearNavigationBar {
    
}


/*********************************************************************************
 Recognizes Touch Pan Events on Comments and
 than looking for neares Comment to Show in
 Comment Box.
 *********************************************************************************/

-(void)pannedComments:(UIPanGestureRecognizer*)recognizer {
    
    if ([recognizer numberOfTouches] > 0) {
        
        CGPoint pt = [recognizer locationOfTouch:0 inView:recognizer.view];
        NSDictionary * comment = [self findNearestComment:pt.x];
        
        //NSLog(@"%@",comment);
        if (comment) {
            [self.commentView setHidden:NO];
            if (comment != nil) {
                self.currentCommentLabel.text = [NSString stringWithFormat:@"%@",[comment objectForKey:@"body"]];
                self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[comment objectForKey:@"user"]objectForKey:@"username"]];
            }
        }
        
        
    }
    
}
/*********************************************************************************
 Looking for nearest Comment and return it
 *********************************************************************************/

-(NSDictionary*)findNearestComment:(int)xPosition {
    
    // 1000 Miliskeunden = 1 Sekunde
    float durationOfTrack = [self.currentTrack.duration floatValue]; // Wir holen uns die Länge des Tracks
    float tolerance =  durationOfTrack * 0.1; // Setzen eines toleranzwertes
    float fingerPositionInMiliseconds = (xPosition/self.commentsView.frame.size.width) *durationOfTrack; // Umrechnung der Finger Position in duration
    
    NSArray *filteredarray = [self.currentComments filteredArrayUsingPredicate:
                              [NSPredicate predicateWithFormat:@"(timestamp >= %@) AND (timestamp <= %@)",
                               [NSNumber numberWithFloat:(fingerPositionInMiliseconds)-tolerance],
                               [NSNumber numberWithFloat:(fingerPositionInMiliseconds)+tolerance]]];
    
    if ([filteredarray firstObject]) {
        
            //float commentCorrection = xPosition /self.view.frame.size.width;
            self.currentCommentView.backgroundColor = [UIColor whiteColor];
            self.currentCommentView.layer.zPosition = 0;
        
            int index = (int)[self.currentComments indexOfObject:[filteredarray objectAtIndex:([filteredarray count]/2)]];
            UIView * currentView = [self.currentCommentViews objectAtIndex:index];
            currentView.layer.zPosition = 1000;
            if (currentView) {
                currentView.backgroundColor = [SRStylesheet mainColor];
                self.currentCommentView = currentView;
                self.currentCommentIndex = index;

            }


    }
    return [filteredarray firstObject];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closePlayerButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// This Methods setsup the AudioPlayer instance for playback Music
-(void)setupTrack {

    self.scrollBar.frame = CGRectMake(0, -3,2,70);
    [self.commentView setHidden:YES];
    
    NSString *streamURL = self.currentTrack.stream_url;
    NSString * yourSCClientID = @"3ceea65b3d83ab630bc818ce1d179a82";
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@", streamURL, yourSCClientID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    self.currentAsset = [AVURLAsset assetWithURL: url];
    self.streamingItem = [AVPlayerItem playerItemWithAsset:self.currentAsset];
    [self.streamingItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.streamingItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.streamingItem];
    //[item addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    
    
    [self.soundPlayer replaceCurrentItemWithPlayerItem:self.streamingItem];

    [self checkLike];
    
}

-(void)checkLike {
        [self.likeButton setEnabled:NO];
        // Check Follow Status
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
        if (self.store.authToken) {
            [parameters setObject:self.store.authToken forKey:@"oauth_token"];
        
        } else {
            [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
        }
    
        // Request all Activities
        [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/me/favorites/%@.json",self.currentTrack.id] parameters:parameters
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             // everything is fine
             self.liked = true;
             [self.likeButton setImage:[UIImage imageNamed:@"redheart"] forState:UIControlStateNormal];
             [self.likeButton setEnabled:YES];

         }
         
                                     failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             self.liked =false;
             [self.likeButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
             [self.likeButton setEnabled:YES];
         }];
        
    
}

-(void)play {
    [self startRunTimeDetection];
    [self.soundPlayer play];
}

-(void) pause {
    [self.soundPlayer pause];
}

-(void)setCurrentTrack:(Track *)currentTrack {
    
    [self.likeButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [self.streamingItem removeObserver:self forKeyPath:@"playbackBufferEmpty" ];
    [self.streamingItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    _currentTrack = currentTrack;
    self.trackIDLabel.text = currentTrack.title;
    self.artistLabel.text = currentTrack.user.username;
    NSString * largeUrl = nil;
    if (currentTrack.artwork_url) {
        largeUrl = [currentTrack.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
    } else {
        largeUrl = [currentTrack.user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:largeUrl]];
        UIImage * image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.artworkImage = image;
        });
        
    });
    
    [self.coverImageView setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:[UIImage imageNamed:@"music"]];
    [self.backGroundView setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:[UIImage imageNamed:@"music"]];
    NSString * string = [currentTrack.waveform_url stringByReplacingOccurrencesOfString:@"https://wis.sndcdn.com/" withString:@"https://w1.sndcdn.com/"];
    [self.waveformImageView setImageWithURL:[NSURL URLWithString:string] placeholderImage:nil];
    
   
    
    [self setupTrack];
    [self setUpComments:currentTrack];
    [self play];
}

- (IBAction)lastCommentButtonPressed:(id)sender
{
    if (self.currentCommentIndex < ([self.currentComments count]- 1)) {
        // Vom letzten aktiven View farbe zurück setzen
        UIView * lastCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [lastCommentView setBackgroundColor:[UIColor whiteColor]];
        self.currentCommentIndex = self.currentCommentIndex +1;
        [lastCommentView.layer setZPosition:10];
        
        
        UIView * currentCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [currentCommentView setBackgroundColor:[SRStylesheet mainColor]];
        self.currentCommentLabel.text =  [[self.currentComments objectAtIndex:self.currentCommentIndex]objectForKey:@"body"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[[self.currentComments objectAtIndex:self.currentCommentIndex] objectForKey:@"user"]objectForKey:@"username"]];
        [currentCommentView.layer setZPosition:1000];
        self.currentCommentView = currentCommentView;
    }
}

- (IBAction)nextCommentButtonPressed:(id)sender {
    
    // Vom letzten aktiven View farbe zurück setzen
    if (self.currentCommentIndex != 0) {
        
        UIView * lastCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [lastCommentView.layer setZPosition:10];
        [lastCommentView setBackgroundColor:[UIColor whiteColor]];
        self.currentCommentIndex = self.currentCommentIndex -1;
        
        UIView * currentCommentView = [[self currentCommentViews]objectAtIndex:self.currentCommentIndex];
        [currentCommentView setBackgroundColor:[SRStylesheet mainColor]];
        self.currentCommentLabel.text =  [[self.currentComments objectAtIndex:self.currentCommentIndex]objectForKey:@"body"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[[self.currentComments objectAtIndex:self.currentCommentIndex] objectForKey:@"user"]objectForKey:@"username"]];
        
        [currentCommentView.layer setZPosition:1000];
        self.currentCommentView = currentCommentView;
        
    }
    
}

- (IBAction)playPauseButtonPressed:(id)sender {
    
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.playButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.playButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    [self initiatePlayback];
}

-(void)initiatePlayback {
    if ([self.soundPlayer rate] != 0.0) {
        [self pause];
    } else [self play];
}

-(void)unsubScribe{
    
    [self.soundPlayer removeObserver:self forKeyPath:@"rate"];
    [self.streamingItem removeObserver:self forKeyPath:@"playbackBufferEmpty" ];
    [self.streamingItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.runTimeDetection = NO;
    [self pause];
}

/**
 *  Keypath handling
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    // Wenn rate vorhanden ist dann wir dgepsielt wenn nicht ist pause
    if ([keyPath isEqualToString:@"rate"]) {
        if ([self.soundPlayer rate]) {
            [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];  // This changes the button to Pause
            [delegate.miniPlayer.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            [self.loadingIndicator stopAnimating];

        }
        else {
            [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];    // This changes the button to Play
            [delegate.miniPlayer.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    }
    
    else if (object == self.streamingItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.streamingItem.playbackBufferEmpty) {
            //Buffer Empty
            //NSLog(@"Buffer Empty");
            [self pause];
        }
    }
    
    else if (object == self.streamingItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (self.streamingItem.playbackLikelyToKeepUp)
        {
            //NSLog(@"Buffer ready");
        }
    }
    else if (object == self.soundPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.soundPlayer.status == AVPlayerStatusReadyToPlay) {
            [self.waveformImageView setUserInteractionEnabled:YES];
        } else if (self.soundPlayer.status == AVPlayerStatusFailed) {
        }
    }
}

/**
 *  Comment Stuff
 *
 *  @param track <#track description#>
 */
-(void)setUpComments:(Track*)track {
    
    for (UIView * v in self.currentCommentViews) {
        [v removeFromSuperview];
    }
    [self.currentCommentViews removeAllObjects];

    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if (self.store.authToken) {
        [parameters setObject:self.store.authToken forKey:@"oauth_token"];
        
    } else {
        [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
    }

    // Request all Activities
    [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/comments.json",track.id] parameters:parameters
        success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         
             NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
             NSMutableArray * array = [responseObject mutableCopy];
             for( int i = 0; i < [array count]; i ++ )
             {
                 NSDictionary * comment = [array objectAtIndex:i];
                 if ([[comment objectForKey:@"timestamp"]isKindOfClass:[NSNull class]]) {
                     [indexes addIndex : i];
                 }
                 
             }
             [array removeObjectsAtIndexes:indexes];
             
             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
             
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             
             NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
             
             [self attachComments:sortedArray];
             self.currentComments = [sortedArray mutableCopy];
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
     }];
    
}

-(void)attachComments:(NSArray *)comments {
    
    if ([comments count]) {
        self.noCommentsLabel.hidden = true;
        // Comments not sorted, so we have to do so
        dispatch_group_t commentgroup = dispatch_group_create();
        dispatch_group_wait(commentgroup, DISPATCH_TIME_FOREVER);
        dispatch_queue_t mainqueue = dispatch_get_main_queue();
        
        dispatch_queue_t uiUpdateQueue = dispatch_queue_create("AttachComments", NULL);
        dispatch_group_notify(commentgroup, uiUpdateQueue, ^{
            //[self commentsReady];
        });
        
        dispatch_group_async(commentgroup,uiUpdateQueue, ^{
            for (NSDictionary *comment in comments) {
                NSString * timeStamp = (NSString*)[comment objectForKey:@"timestamp"];
                
                // Bug OVER HERE SOMETIMES
                //float duration = CMTimeGetSeconds(self.currentAsset.duration); // we should use duration that soundcloud api returns and not something else
                float duration = [self.currentTrack.duration floatValue] / 1000;
                float widthOfWaveFormView = self.waveformImageView.layer.bounds.size.width;
                
                
                float xPosition = ((([timeStamp floatValue])/1000.0)/duration)*widthOfWaveFormView;
                
                // BUGAREA
                if (!isnan(xPosition)) {
                    
                    
                    // NAN BUG STILL EXISTS
                    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(xPosition,0, 1, 60)];
                    view.backgroundColor = [UIColor whiteColor];
                    [[self currentCommentViews]addObject:view];
                    
                    dispatch_group_async(commentgroup,mainqueue, ^{
                        [self.commentsView addSubview:view];
                        
                    });
                }
            }
        });
    }
    
    else {
        self.noCommentsLabel.hidden = false;
    }

}

/*********************************************************************************
Detects runtime Biatch
 *********************************************************************************/
-(void) startRunTimeDetection {
    
    __block float duration;
    __block float currentTime;
    __block float availableDuration;
    
    dispatch_queue_t uiUpdateQueue = dispatch_queue_create("PlayerUpdater", NULL);
    dispatch_async(uiUpdateQueue, ^{
        while (self.runTimeDetection) {
            
            
            
            
            [NSThread sleepForTimeInterval:0.2f];
            duration = CMTimeGetSeconds(self.soundPlayer.currentItem.duration);
            currentTime = CMTimeGetSeconds(self.soundPlayer.currentItem.currentTime);
            
            // Update Layer
            
            float prozentual = (float)(currentTime/ duration);
            CGRect newFrame = CGRectMake(self.waveformImageView.layer.bounds.size.width * prozentual,0 ,2 ,70);
            
            // Calculate buffering Width
            availableDuration = [self availableDuration];
            float  prozentualBuffering = (float)(availableDuration/duration);
            CGFloat widthOfBufferingSzone = (self.waveformImageView.frame.size.width * (1.0-prozentualBuffering)) ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @try {
                    // Update Buffering zone
                    if (!self.bufferingSzone) {
                        self.bufferingSzone = [[UIView alloc]initWithFrame:CGRectMake(self.waveformImageView.frame.origin.x, self.waveformImageView.frame.origin.y,widthOfBufferingSzone, self.waveformImageView.frame.size.height)];
                        self.bufferingSzone.backgroundColor = [SRStylesheet lightGrayColor];
                        self.bufferingSzone.userInteractionEnabled =NO;
                        self.waveformImageView.layer.zPosition = 200;
                        self.bufferingSzone.layer.zPosition = 100;
                        [self.contentViewofVisualEffectView addSubview:self.bufferingSzone];


                    } else {
                        self.bufferingSzone.frame = CGRectMake(self.waveformImageView.frame.size.width-widthOfBufferingSzone, self.waveformImageView.frame.origin.y,widthOfBufferingSzone, self.waveformImageView.frame.size.height);
                    };
                } @catch(NSException *exception) {
                    // Do something
                }

                
                // Setze das Zeit label
                
                NSUInteger h_current = (NSUInteger)currentTime / 3600;
                NSUInteger m_current = ((NSUInteger)currentTime / 60) % 60;
                NSUInteger s_current = (NSUInteger)currentTime % 60;
                
                NSUInteger h_duration = (NSUInteger)duration / 3600;
                NSUInteger m_duration= ((NSUInteger)duration/ 60) % 60;
                NSUInteger s_duration = (NSUInteger)duration % 60;
                
                NSString *formattedCurrent;
                NSString *formattedDuration;
                if (h_duration == 0) {
                    formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m_current, (unsigned long)s_current];
                    formattedDuration = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m_duration, (unsigned long)s_duration];
                } else {
                    formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h_current, (unsigned long)m_current, (unsigned long)s_current];
                    formattedDuration = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h_duration, (unsigned long)m_duration, (unsigned long)s_duration];
                }
                
                self.durationLabel.text = [NSString stringWithFormat:@"%@ / %@",formattedCurrent,formattedDuration];
                NSArray *keys = [NSArray arrayWithObjects:
                                 MPMediaItemPropertyPlaybackDuration,
                                 MPNowPlayingInfoPropertyElapsedPlaybackTime,
                                 MPMediaItemPropertyTitle,
                                 MPMediaItemPropertyArtist,
                                 MPMediaItemPropertyArtwork,
                                 nil];
                
                MPMediaItemArtwork * image = nil;
                if (self.artworkImage) {
                    image  =  [[MPMediaItemArtwork alloc]initWithImage:self.artworkImage];
                } else {
                    image = [[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:@"music"]];
                }
                
                NSArray *values = [NSArray arrayWithObjects:

                                   [NSNumber numberWithFloat:duration],
                                   [NSNumber numberWithFloat:currentTime],
                                   self.currentTrack.title,
                                   self.currentTrack.user.username,
                                   image,
                                   nil];
                NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
                
                @try {
                    [self.scrollBar setFrame:newFrame];
                    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [delegate.miniPlayer.scrollbarMiniPlayer setFrame:CGRectMake(0, 0, delegate.miniPlayer.layer.bounds.size.width * prozentual, 4)];
                } @catch(NSException *exception) {
                    // Do something
                }
            }); // dispatch Block
        }
        
    });
}

-(NSTimeInterval)availableDuration {
    NSArray * loadedTimeRanges = [[self.soundPlayer currentItem]loadedTimeRanges];
    if ([loadedTimeRanges count] != 0 ) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0]CMTimeRangeValue];
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;
        return  result;
    }
    
    return 0;
    
}

- (void)tappedWaveform:(UITapGestureRecognizer *)recognizer {

    if (self.streamingItem.status == AVPlayerItemStatusReadyToPlay) {
        
        [self.loadingIndicator startAnimating];
        self.runTimeDetection = false;
        CGPoint location = [recognizer locationInView:[recognizer.view superview]];
        CGFloat width = self.waveformImageView.layer.bounds.size.width;
        float prozentual = (float)(location.x / width);
        CGRect newFrame = CGRectMake(0, -3, self.waveformImageView.layer.bounds.size.width * prozentual, self.scrollBar.layer.bounds.size.height);
        
        [self.scrollBar setFrame:newFrame];
        float secondsOfTrack = CMTimeGetSeconds(([[[self.soundPlayer currentItem] asset] duration]));
        float timeAfterScrub = prozentual * secondsOfTrack;
        [self.soundPlayer seekToTime:CMTimeMake((int)timeAfterScrub, 1) completionHandler:^(BOOL finished){
            if (finished)
            {
                // Do stuff
                self.runTimeDetection = true;
                [self startRunTimeDetection];
                [self.loadingIndicator stopAnimating];
            }
            /* do stuff */
            else {
                
            }
            /* do other stuff */
        }];
    }
    
}

- (void)pannedWaveform:(UIPanGestureRecognizer *)recognizer {
    
    if (self.streamingItem.status == AVPlayerItemStatusReadyToPlay) {
        
        self.runTimeDetection = false;
        CGPoint location = [recognizer locationInView:[recognizer.view superview]];
        CGFloat width = self.waveformImageView.layer.bounds.size.width;
        float prozentual = (float)(location.x / width);
        CGRect newFrame = CGRectMake(self.waveformImageView.layer.bounds.size.width * prozentual, 0, 2, self.scrollBar.layer.bounds.size.height);
        
        [self.scrollBar setFrame:newFrame];
        float secondsOfTrack = CMTimeGetSeconds(([[[self.soundPlayer currentItem] asset] duration]));
        float timeAfterScrub = prozentual * secondsOfTrack;
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self.loadingIndicator startAnimating];
            [self.soundPlayer seekToTime:CMTimeMake((int)timeAfterScrub, 1) completionHandler:^(BOOL finished){
                if (finished)
                {
                    // Do stuff
                    self.runTimeDetection = true;
                    [self startRunTimeDetection];
                    [self.loadingIndicator stopAnimating];
                }
                /* do stuff */
                else {
                    
                }
                /* do other stuff */
            }];
        }
    
    }
    
}

// Like and dislike stuff
-(IBAction)favButtonPressed:(id)sender{
    [self.likeButton setEnabled:NO];
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.likeButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
         self.likeButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    
    if (self.liked) {
        [[SoundtraceClient sharedClient] DELETE:[NSString stringWithFormat:@"/me/favorites/%@",self.currentTrack.id] parameters:parameters
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             [self.likeButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
             [self.likeButton setEnabled:YES];
             self.liked = NO;

         }
         
         failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             [self.likeButton setEnabled:YES];

         }];
    } else {
        
        [[SoundtraceClient sharedClient] PUT:[NSString stringWithFormat:@"/me/favorites/%@",self.currentTrack.id] parameters:parameters
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             [self.likeButton setImage:[UIImage imageNamed:@"redheart"] forState:UIControlStateNormal];
             [self.likeButton setEnabled:YES];
             self.liked = YES;

         }
         
         failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             [self.likeButton setEnabled:YES];

         }];
    }
    // Request all Activities

}

-(void)stop {
    self.streamingItem = nil;
}

-(void)showNext {
    [self performSegueWithIdentifier:@"showNext" sender:self];
}

- (IBAction)lastTrackButtonPressed:(id)sender {
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.lastTrackButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.lastTrackButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    [self playLastTrack];
    
    
}
- (IBAction)nextTrackButtonPressed:(id)sender {
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.nextTrackButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.nextTrackButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    
    
    [self playNextTrack];
}

-(void)playNextTrack {
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSIndexPath * index = delegate.playingIndex;
    NSMutableArray * currentTracks = delegate.upNext;
    if ((index.row+1)< [currentTracks count]) {
        [delegate setPlayingIndex:[NSIndexPath indexPathForItem:index.row+1 inSection:1]];
        [delegate setupPlayerWithtrack:[currentTracks objectAtIndex:index.row +1]];
    }
}

-(void)playLastTrack {
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSIndexPath * index = delegate.playingIndex;
    NSMutableArray * currentTracks = delegate.upNext;
    if ((index.row-1)>= 0) {
        [delegate setPlayingIndex:[NSIndexPath indexPathForItem:index.row+-1 inSection:1]];
        [delegate setupPlayerWithtrack:[currentTracks objectAtIndex:index.row -1]];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCommentsSegue"]) {
        CommentsTableViewController * dc = (CommentsTableViewController*)segue.destinationViewController;
        dc.currentTrack = self.currentTrack;
    }
}
- (IBAction)showVolumeFaceButtonPressed:(id)sender {
        if (self.volumeViewActive) {
            [self hideVolumeView];
        }
        else {
            [self showVolumeFaderView];
        }

}

-(void)showVolumeFaderView{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.volumeControlView.frame = CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60);
    self.volumeViewActive = YES;
    
    
    [UIView commitAnimations];
}
-(void)hideVolumeView{
    self.volumeViewActive = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.volumeControlView.frame = CGRectMake(0, self.view.frame.size.height+60, self.view.frame.size.width, 60);
    
    [UIView commitAnimations];
}

@end
