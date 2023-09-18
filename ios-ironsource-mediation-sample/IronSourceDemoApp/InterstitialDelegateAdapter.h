//
//  InterstitialDelegateAdapter.h
//  IronSourceDemoApp
//
//  Created by Ihor Vasylkov on 31.08.2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IronSource/IronSource.h>

NS_ASSUME_NONNULL_BEGIN

@class InterstitialDelegateAdapter;

@protocol InterstitialDelegateAdapterDelegate<NSObject>
- (void)interstitialDidLoad;
- (void)interstitialDidFailToLoadWithError:(NSError *)error;
- (void)interstitialDidOpen;
- (void)interstitialDidShow;
- (void)interstitialDidFailToShowWithError:(NSError *)error;
- (void)didClickInterstitial;
- (void)interstitialDidClose;
@end

@interface InterstitialDelegateAdapter : NSObject<LevelPlayInterstitialDelegate>
@property (nonatomic, weak, nullable) id<InterstitialDelegateAdapterDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
