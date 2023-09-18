/**
 * Copyright 2022 Start.io Inc
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

#import <StartApp/StartApp.h>
#import "ISStartAppCustomBanner.h"
#import "IronSource/ISAdapterErrors.h"
#import "ISStartAppExtras.h"

@interface STABannerToISCallbacksAdapter : NSObject<STABannerDelegateProtocol>
@property (nonatomic) id<ISBannerAdDelegate> isBannerAdDelegate;
@end

@interface ISBannerSize (StartIOExtensions)

- (NSValue *)com_sta_sizeWithContainingViewController:(UIViewController *)viewController;

@end

@interface ISStartAppCustomBanner()<STABannerDelegateProtocol>

@property (nonatomic, strong) STABannerLoader *bannerLoader;
@property (nonatomic, strong) id<STABannerDelegateProtocol> bannerDelegate;


@end

@implementation ISStartAppCustomBanner

- (void)loadAdWithAdData:(nonnull ISAdData *)adData
     viewController:(UIViewController *)viewController
          size:(ISBannerSize *)size
        delegate:(nonnull id<ISBannerAdDelegate>)delegate {
    
    dispatch_block_t performBlock = ^{
        STABannerSize staSizeToLoad;
        NSValue *staBannerSizeAsValue = [size com_sta_sizeWithContainingViewController:viewController];
        if (nil == staBannerSizeAsValue) {
            if ([delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
                [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                             errorCode:ISAdapterErrorInternal
                                          errorMessage:@"banner size not supported"];
            }
        };
        
        [staBannerSizeAsValue getValue:&staSizeToLoad];
        
        ISStartAppExtras *extras = [[ISStartAppExtras alloc] initWithParamsDictionary:adData.configuration];
        STAAdPreferences *adPrefs = extras.prefs;
        
        [self performBannerLoadWitnSize:staSizeToLoad preferences:adPrefs delegate:delegate];
    };
    
    if (NSThread.isMainThread) {
        performBlock();
    } else dispatch_async(dispatch_get_main_queue(), performBlock);
}

- (void)performBannerLoadWitnSize:(STABannerSize)bannerSize preferences:(STAAdPreferences *)preferences delegate:(nonnull id<ISBannerAdDelegate>) delegate {
    self.bannerLoader = [[STABannerLoader alloc] initWithSize:bannerSize adPreferences:preferences];
    [self.bannerLoader loadAdWithCompletion:^(STABannerViewCreator *creator, NSError *error) {
        if (error != nil) {
            if ([delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
                [delegate adDidFailToLoadWithErrorType:(error.code == STAErrorNoContent) ? ISAdapterErrorTypeNoFill : ISAdapterErrorTypeInternal
                                                  errorCode:ISAdapterErrorInternal
                                               errorMessage:error.localizedDescription];
            }
        }
        else {
            STABannerToISCallbacksAdapter *callbacksAdapter = [STABannerToISCallbacksAdapter new];
            callbacksAdapter.isBannerAdDelegate = delegate;
            self.bannerDelegate = callbacksAdapter;
            STABannerViewBase *banner = [creator createBannerViewForDelegate:callbacksAdapter supportAutolayout:NO];
            [delegate adDidLoadWithView:banner];
        }
    }];
}

#pragma mark -
- (void)destroyAdWithAdData:(nonnull ISAdData *)adData {
    self.bannerLoader = nil;
    self.bannerDelegate = nil;
}

@end

@implementation STABannerToISCallbacksAdapter

- (void) didSendImpressionForBannerAd:(STABannerViewBase *)banner {
    [self.isBannerAdDelegate adDidOpen];
}

- (void)didClickBannerAd:(STABannerViewBase *)banner {
    [self.isBannerAdDelegate adDidClick];
}

@end

@implementation ISBannerSize (StartIOExtensions)

- (NSValue *)com_sta_sizeWithContainingViewController:(UIViewController *)viewController {
    ISBannerSize *runtimeISBannerSize = self;
    if (self.isSmart) {
        if (
            UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
            //IronSource returns banner size according to interface idiom, not the size of screen
            //viewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
            ) {
                runtimeISBannerSize = ISBannerSize_LEADERBOARD;
            } else {
                runtimeISBannerSize = ISBannerSize_BANNER;
            }
    }
    STABannerSize staBannerSize = { CGSizeMake(runtimeISBannerSize.width, runtimeISBannerSize.height), false };
    NSValue *result = [NSValue value:&staBannerSize withObjCType:@encode(STABannerSize)];
    return result;
}

@end
