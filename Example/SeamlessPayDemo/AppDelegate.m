/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@import SeamlessPayCore;

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Override point for customization after application launch.
  NSString *secretkey = [[NSUserDefaults standardUserDefaults] objectForKey:@"secretkey"];
  NSString *publishableKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"publishableKey"];
  SPEnvironment env = [[NSUserDefaults standardUserDefaults] integerForKey:@"env"];

  if (!publishableKey) {
    publishableKey = @"pk_XXXXXXXXXXXXXXXXXXXXXXXXXX";
    secretkey = @"sk_XXXXXXXXXXXXXXXXXXXXXXXXXX";
    env = SPEnvironmentSandbox;
    [[NSUserDefaults standardUserDefaults] setObject:publishableKey forKey:@"publishableKey"];
    [[NSUserDefaults standardUserDefaults] setObject:secretkey forKey:@"secretkey"];
    [[NSUserDefaults standardUserDefaults] setInteger:env forKey:@"env"];
  }

  [[SPAPIClient getSharedInstance] setSecretKey:secretkey
                                 publishableKey:publishableKey
                                    environment:env];

  return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:
(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
  return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                        sessionRole:connectingSceneSession.role];
}

@end
