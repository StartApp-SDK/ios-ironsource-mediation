/**
 * Copyright 2026 Start.io Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ViewController.h"
#import "NativeAdView.h"
#import "modern-objc.h"
#import <IronSource/IronSource.h>

static let kInterstitialUnitId = @"<INTERSTITIAL_UNIT_ID>";
static let kRewardedUnitId = @"<REWARDED_UNIT_ID>";
static let kNativeUnitId = @"<NATIVE_UNIT_ID>";
static let kBannerUnitId = @"<BANNER_UNIT_ID>";
static let kMrecUnitId = @"<MREC_UNIT_ID>";

@interface ViewController () <LPMInterstitialAdDelegate, LPMRewardedAdDelegate, LPMBannerAdViewDelegate, LevelPlayNativeAdDelegate>

@property (weak, nonatomic) IBOutlet UITextView* messageTextView;
@property (weak, nonatomic) IBOutlet UIButton* showInterstitialButton;
@property (weak, nonatomic) IBOutlet UIButton* showRewardedButton;
@property (weak, nonatomic) IBOutlet UIButton* showNativeButton;

@property (nonatomic, nullable) LPMInterstitialAd *interstitialAd;
@property (nonatomic, nullable) LPMRewardedAd *rewardedAd;
@property (nonatomic, nullable) LPMBannerAdView *bannerAd;
@property (nonatomic, nullable) LevelPlayNativeAd *nativeAd;
@property (nonatomic, nullable) NativeAdView  *nativeAdView;


@property (nonatomic) BOOL needToStrechInlineView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Interstitial

- (IBAction)loadInterstitial:(UIButton*)sender {
    self.interstitialAd = [[LPMInterstitialAd alloc] initWithAdUnitId:kInterstitialUnitId];
    self.interstitialAd.delegate = self;
    
    // Load the first ad
    [self.interstitialAd loadAd];
}

- (IBAction)showInterstitial:(UIButton*)sender {
    if ([self.interstitialAd isAdReady]) {
        [self.interstitialAd showAdWithViewController:self placementName:@"Interstitial"];
    }
}

#pragma mark - Rewarded

- (IBAction)loadRewarded:(UIButton*)sender {
    self.rewardedAd = [[LPMRewardedAd alloc] initWithAdUnitId:kRewardedUnitId];
    self.rewardedAd.delegate = self;
    
    // Load the first ad
    [self.rewardedAd loadAd];
}

- (IBAction)showRewarded:(UIButton*)sender {
    if ([self.rewardedAd isAdReady]) {
        [self.rewardedAd showAdWithViewController:self placementName:@"Rewarded"];
    }
}

#pragma mark - Native

- (IBAction)loadNative:(UIButton*)sender {
    self.nativeAd = [[[[LevelPlayNativeAdBuilder new] withViewController:self] withPlacementName:@"Native"] withDelegate:self].build;
    [self.nativeAd loadAd];
    
    self.nativeAdView = [[NativeAdView alloc] init];
}

- (IBAction)showNative:(UIButton*)sender {
    [self cleanBottomEdge];
    self.showNativeButton.enabled = NO;
    [self addViewCenteredOnBottomEdge:self.nativeAdView withSize:CGSizeMake(300, 250)];
}

#pragma mark - Banner

- (IBAction)loadBanner:(UIButton*)sender {
    [self cleanBottomEdge];
    
    // Create ad configuration - optional
    LPMBannerAdViewConfigBuilder *adConfigBuilder = [LPMBannerAdViewConfigBuilder new];
    [adConfigBuilder setWithAdSize:LPMAdSize.bannerSize];
    [adConfigBuilder setWithPlacementName:@"Banner"];
    LPMBannerAdViewConfig *adConfig = [adConfigBuilder build];
    
    // Create the banner view and set the ad unit id
    self.bannerAd = [[LPMBannerAdView alloc] initWithAdUnitId:kBannerUnitId config:adConfig];
    [self.bannerAd setDelegate:self];
    [self.bannerAd loadAdWithViewController:self];
}

#pragma mark - MREC

- (IBAction)loadMREC:(UIButton*)sender {
    [self cleanBottomEdge];
    
    // Create ad configuration - optional
    LPMBannerAdViewConfigBuilder *adConfigBuilder = [LPMBannerAdViewConfigBuilder new];
    [adConfigBuilder setWithAdSize:LPMAdSize.mediumRectangleSize];
    [adConfigBuilder setWithPlacementName:@"MRec"];
    LPMBannerAdViewConfig *adConfig = [adConfigBuilder build];
    
    // Create the banner view and set the ad unit id
    self.bannerAd = [[LPMBannerAdView alloc] initWithAdUnitId:kMrecUnitId config:adConfig];
    [self.bannerAd setDelegate:self];
    [self.bannerAd loadAdWithViewController:self];
}

#pragma mark - Utils

- (void)addViewCenteredOnBottomEdge:(UIView*)view withSize:(CGSize)size {
    [self addViewAnimated:view];
    [NSLayoutConstraint activateConstraints:@[
        [view.widthAnchor constraintEqualToConstant:size.width],
        [view.heightAnchor constraintEqualToConstant:size.height],
        [view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
}

- (void)addViewStretchedOnBottomEdge:(UIView*)view height:(CGFloat)height {
    [self addViewAnimated:view];
    [NSLayoutConstraint activateConstraints:@[
        [view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [view.heightAnchor constraintEqualToConstant:height]
    ]];
}

- (void)addViewAnimated:(UIView*)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:view];
    
    view.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        view.alpha = 1;
    }];
}

- (void)cleanBottomEdge {
    [self.bannerAd removeFromSuperview];
    [self.nativeAdView removeFromSuperview];
}

- (void)logMessage:(nonnull NSString*)message {
    [self.messageTextView insertText:[@"\n" stringByAppendingString:message]];
    let bottom = NSMakeRange(self.messageTextView.text.length - 1, 1);
    [self.messageTextView scrollRangeToVisible:bottom];
    
    NSLog(@"%@", message);
}

- (void)enable:(BOOL)enable showButtonForAdUnit:(nonnull NSString *)adUnit {
    if ([adUnit isEqualToString:kInterstitialUnitId]) {
        self.showInterstitialButton.enabled = enable;
    }
    else if ([adUnit isEqualToString:kRewardedUnitId]) {
        self.showRewardedButton.enabled = enable;
    }
    else if ([adUnit isEqualToString:kNativeUnitId]) {
        self.showNativeButton.enabled = enable;
    }
}

#pragma mark - LPMInterstitialAdDelegate Methods
- (void)didLoadAdWithAdInfo:(LPMAdInfo *)adInfo {
    [self enable:YES showButtonForAdUnit:adInfo.adUnitId];
    if ([adInfo.adUnitId isEqualToString:kBannerUnitId]) {
        [self addViewStretchedOnBottomEdge:self.bannerAd height:LPMAdSize.bannerSize.height];
    }
    else if ([adInfo.adUnitId isEqualToString:kMrecUnitId]) {
        [self addViewStretchedOnBottomEdge:self.bannerAd height:LPMAdSize.mediumRectangleSize.height];
    }
}
- (void)didFailToLoadAdWithAdUnitId:(NSString *)adUnitId error:(NSError *)error {
    [self logMessage:NSStringFromSelector(_cmd)];
    [self enable:NO showButtonForAdUnit:adUnitId];
}
- (void)didDisplayAdWithAdInfo:(LPMAdInfo *)adInfo {
    [self logMessage:NSStringFromSelector(_cmd)];
    [self enable:NO showButtonForAdUnit:adInfo.adUnitId];
}
- (void)didFailToDisplayAdWithAdInfo:(LPMAdInfo *)adInfo error:(NSError *)error {
    [self logMessage:NSStringFromSelector(_cmd)];
    [self enable:NO showButtonForAdUnit:adInfo.adUnitId];
}
- (void)didClickAdWithAdInfo:(LPMAdInfo *)adInfo {
    [self logMessage:NSStringFromSelector(_cmd)];
}
- (void)didCloseAdWithAdInfo:(LPMAdInfo *)adInfo {
    [self logMessage:NSStringFromSelector(_cmd)];
    [self enable:NO showButtonForAdUnit:adInfo.adUnitId];
}

#pragma mark - LPMRewardedAdDelegate Methods
- (void)didRewardAdWithAdInfo:(LPMAdInfo *)adInfo reward:(LPMReward *)reward {
    [self logMessage:NSStringFromSelector(_cmd)];
}


#pragma mark - LevelPlayNativeAdDelegate
- (void)didFailToLoad:(nonnull LevelPlayNativeAd *)nativeAd withError:(nonnull NSError *)error {
    [self logMessage:NSStringFromSelector(_cmd)];
    [self enable:NO showButtonForAdUnit:kNativeUnitId];
}

- (void)didLoad:(nonnull LevelPlayNativeAd *)nativeAd withAdInfo:(nonnull ISAdInfo *)adInfo {
    [self enable:YES showButtonForAdUnit:kNativeUnitId];
    [self.nativeAdView populateWithContent:nativeAd];
    
}

- (void)didClick:(nonnull LevelPlayNativeAd *)nativeAd withAdInfo:(nonnull ISAdInfo *)adInfo {
    [self logMessage:NSStringFromSelector(_cmd)];
}

- (void)didRecordImpression:(nonnull LevelPlayNativeAd *)nativeAd withAdInfo:(nonnull ISAdInfo *)adInfo {
    [self logMessage:NSStringFromSelector(_cmd)];
}

@end
