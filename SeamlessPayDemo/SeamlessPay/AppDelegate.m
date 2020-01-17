//
//  AppDelegate.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "AppDelegate.h"

@import SeamlessPayCore;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    NSString *secretkey = [[NSUserDefaults standardUserDefaults] objectForKey:@"secretkey"];
    NSString *publishableKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"publishableKey"];

    [[SPAPIClient getSharedInstance] setSecretKey:secretkey?:@"sk_XXXXXXXXXXXXXXXXX"
                                   publishableKey:publishableKey?:@"pk_XXXXXXXXXXXXXXXXX"
                                          sandbox:YES];

//    [[SPAPIClient getSharedInstance] setSecretKey:@"sk_XXXXXXXXXXXXXXX"
//                                     publicKey:@"pk_XXXXXXXXXXXXXXXXXX"
//                                       sandbox:NO];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
