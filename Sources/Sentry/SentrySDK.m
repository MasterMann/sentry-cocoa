//
//  SentrySDK.m
//  Sentry
//
//  Created by Klemens Mantzos on 12.11.19.
//  Copyright © 2019 Sentry. All rights reserved.
//


#if __has_include(<Sentry/Sentry.h>)
#import <Sentry/SentrySDK.h>
#import <Sentry/SentryClient.h>
#import <Sentry/SentryScope.h>
#import <Sentry/SentryBreadcrumb.h>
#import <Sentry/SentryDefines.h>
#import <Sentry/SentryHub.h>
#import <Sentry/SentryBreadcrumbTracker.h>
#else
#import "SentrySDK.h"
#import "SentryClient.h"
#import "SentryScope.h"
#import "SentryBreadcrumb.h"
#import "SentryDefines.h"
#import "SentryHub.h"
#import "SentryBreadcrumbTracker.h"
#endif

@interface SentrySDK ()

/**
 holds the current hub instance
 */
@property (class) SentryHub * currentHub; // TODO(fetzig) check if copy is needed

@end

NS_ASSUME_NONNULL_BEGIN
@implementation SentrySDK

static SentryHub * currentHub;

+ (SentryHub *) currentHub {
    @synchronized(self) {
        if (nil == currentHub) {
            currentHub = [[SentryHub alloc] init];
        }
        return currentHub;
    }
}

+ (void) setCurrentHub:(SentryHub *)hub {
    @synchronized(self) {
        currentHub = hub;
    }
}

+ (void)startWithOptionsDict:(NSDictionary<NSString *,id> *)optionsDict {
    NSError *error = nil;
    SentryOptions *options = [[SentryOptions alloc] initWithDict:optionsDict didFailWithError:&error];
    if (nil != error) {
        NSLog(@"%@", error);
    } else {
        [SentrySDK startWithOptions:options];
    }
}

+ (void)startWithOptions:(SentryOptions *)options {
    if ([SentrySDK.currentHub getClient] == nil) {
        SentryClient *newClient = [[SentryClient alloc] initWithOptions:options];
        [SentrySDK.currentHub bindClient:newClient];
    }
}

+ (void)captureEvent:(SentryEvent *)event {
    [SentrySDK.currentHub captureEvent:event];
}

+ (void)captureError:(NSError *)error {
    SentryEvent *event = [[SentryEvent alloc] initWithLevel:kSentrySeverityError];
    event.message = error.localizedDescription;
    [SentrySDK captureEvent:event];
}

+ (void)captureException:(NSException *)exception {
    SentryEvent *event = [[SentryEvent alloc] initWithLevel:kSentrySeverityError];
    event.message = exception.reason;
    [SentrySDK captureEvent:event];
}

+ (void)captureMessage:(NSString *)message {
    SentryEvent *event = [[SentryEvent alloc] initWithLevel:kSentrySeverityInfo];
    event.message = message;
    [SentrySDK captureEvent:event];
}

+ (void)addBreadcrumb:(SentryBreadcrumb *)crumb {
    [SentrySDK.currentHub addBreadcrumb:crumb];
}

// TODO(fetzig): requires scope that is detached from SentryClient.finish this as soon as SentryScope has been implemented.
+ (void)configureScope:(void(^)(SentryScope *scope))callback {
    [SentrySDK.currentHub configureScope:callback];
}

#ifndef __clang_analyzer__
// Code not to be analyzed
+ (void)crash {
    int* p = 0;
    *p = 0;
}
#endif

@end

NS_ASSUME_NONNULL_END
