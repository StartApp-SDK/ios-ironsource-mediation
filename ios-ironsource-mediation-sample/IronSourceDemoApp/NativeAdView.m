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

#import "NativeAdView.h"

@implementation NativeAdView
- (instancetype)init {
    UINib *nib = [UINib nibWithNibName:@"ISNativeAdView" bundle:[NSBundle mainBundle]];
    
    NSArray *nibContents = [nib instantiateWithOwner:nil options:nil];
    self.nativeAdView = (ISNativeAdView *)[nibContents firstObject];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}
// This function will be useful once the didLoad call back arrives
- (void)populateWithContent:(nonnull LevelPlayNativeAd *)nativeAd {
    // Assigning views contents to the nativeAdView
    if (nativeAd.icon.image) {
        self.nativeAdView.adAppIcon.image = nativeAd.icon.image;
    } else {
        [self.nativeAdView.adAppIcon removeFromSuperview];
    }
    if (nativeAd.title) {
        self.nativeAdView.adTitleView.text = nativeAd.title;
    }
    if (nativeAd.advertiser) {
        self.nativeAdView.adAdvertiserView.text = nativeAd.advertiser;
    }
    if (nativeAd.body) {
        self.nativeAdView.adBodyView.text = nativeAd.body;
    }
    if (nativeAd.callToAction) {
        [self.nativeAdView.adCallToActionView setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    // To ensure proper processing of touch events by the SDK, user interaction should be disabled
        self.nativeAdView.adCallToActionView.userInteractionEnabled = NO;
    }
    // call function to register native ad
    [self.nativeAdView registerNativeAdViews:nativeAd];
}
@end
