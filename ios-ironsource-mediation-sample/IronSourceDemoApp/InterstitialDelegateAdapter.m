//
//  InterstitialDelegateAdapter.m
//  IronSourceDemoApp
//
//  Created by Ihor Vasylkov on 31.08.2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#import "InterstitialDelegateAdapter.h"

@implementation InterstitialDelegateAdapter


- (void)didClickWithAdInfo:(ISAdInfo *)adInfo {
    [self.delegate didClickInterstitial];
}

- (void)didCloseWithAdInfo:(ISAdInfo *)adInfo {
    [self.delegate interstitialDidClose];
}

- (void)didFailToLoadWithError:(NSError *)error {
    [self.delegate interstitialDidFailToLoadWithError:error];
}

- (void)didFailToShowWithError:(NSError *)error andAdInfo:(ISAdInfo *)adInfo {
    [self.delegate interstitialDidFailToShowWithError:error];
}

- (void)didLoadWithAdInfo:(ISAdInfo *)adInfo {
    [self.delegate interstitialDidLoad];
}

- (void)didOpenWithAdInfo:(ISAdInfo *)adInfo {
    [self.delegate interstitialDidOpen];
}

- (void)didShowWithAdInfo:(ISAdInfo *)adInfo {
    [self.delegate interstitialDidShow];
}

@end
