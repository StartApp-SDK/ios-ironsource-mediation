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

#import "ISStartAppMainThreadDispatcher.h"

@implementation ISStartAppMainThreadDispatcher
+ (void)dispatchSyncBlock:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

+ (id)dispatchSyncBlockWithReturn:(id _Nullable (^)(void))block {
    __block id returnValue = nil;
    if ([NSThread isMainThread]) {
        returnValue = block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            returnValue = block();
        });
    }
    return returnValue;
}
@end
