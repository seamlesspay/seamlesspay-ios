//
//  AppDelegate.m
//  SeamlessPayDemo
//
//  Copyright © 2020 Seamless Payments, Inc. All rights reserved.
//

@import SeamlessPayCore;

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *secretkey = [[NSUserDefaults standardUserDefaults] objectForKey:@"secretkey"];
    NSString *publickey = [[NSUserDefaults standardUserDefaults] objectForKey:@"publickey"];
    NSString *env = [[NSUserDefaults standardUserDefaults] objectForKey:@"env"];
    
    if (!publickey) {
        publickey = @"pk_XXXXXXXXXXXXXXXXXXXXXXXXXX";
        secretkey = @"sk_XXXXXXXXXXXXXXXXXXXXXXXXXX";
        env = @"sandbox";
        [[NSUserDefaults standardUserDefaults] setObject:publickey forKey:@"publickey"];
        [[NSUserDefaults standardUserDefaults] setObject:secretkey forKey:@"secretkey"];
        [[NSUserDefaults standardUserDefaults] setObject:env forKey:@"env"];
    }
    
    [[SPAPIClient getSharedInstance] setSecretKey:secretkey
                                        publicKey:publickey
                                          sandbox:[env isEqualToString:@"sandbox"]];
    
    
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
