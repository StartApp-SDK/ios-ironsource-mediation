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
#import "IronSource/ISAdapterErrors.h"
#import "ISStartAppCustomAdapter.h"
#import "ISStartAppConstants.h"
#import "ISStartAppMainThreadDispatcher.h"

@implementation ISStartAppCustomAdapter

#pragma mark ISAdapterBaseProtocol methods
- (void)init:(ISAdData *)adData delegate:(id<ISNetworkInitializationDelegate>)delegate {
    NSString *appID = adData.configuration[ISStartAppKeyAppID];
    if (appID.length == 0) {
        ISAdapterConfig *adapterConfig = adData.adUnitData[ISStartAppKeyAdapterConfig];
        appID = adapterConfig.appSettings[ISStartAppKeyAppID];
    }
    
    if (appID.length == 0) {
        if ([delegate respondsToSelector:@selector(onInitDidFailWithErrorCode:errorMessage:)]) {
            [delegate onInitDidFailWithErrorCode:ISAdapterErrorMissingParams errorMessage:@"Missing StartAppSDK AppID parameter"];
        }
    }
    else {
        __weak typeof(self)weakSelf = self;
        [ISStartAppMainThreadDispatcher dispatchSyncBlock:^{
            [weakSelf setupStartioSDKWithAppID:appID adData:adData];
        }];
        
        if ([delegate respondsToSelector:@selector(onInitDidSucceed)]) {
            [delegate onInitDidSucceed];
        }
    }
}

- (void)setupStartioSDKWithAppID:(NSString *)appID adData:(ISAdData *)adData {
    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = appID;
    [sdk enableMediationModeFor:@"IronSource" version:ISStartAppAdapterVersion];
}

- (NSString *)networkSDKVersion {
    return [ISStartAppMainThreadDispatcher dispatchSyncBlockWithReturn:^id _Nullable{
        return [[STAStartAppSDK sharedInstance] version];
    }];
}

- (NSString *)adapterVersion {
    return ISStartAppAdapterVersion;
}

#pragma mark ISAdapterConsentProtocol methods
- (void)setConsent:(BOOL)consent {
    [ISStartAppMainThreadDispatcher dispatchSyncBlock:^{
        STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
        [sdk handleExtras:^(NSMutableDictionary<NSString *,id> *extras) {
            extras[@"medPas"] = @(consent);
        }];
    }];
}

@end
