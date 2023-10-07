//
//  AppDelegate.m
//  SPPaymentViewController
//

#import "AppDelegate.h"

@import SeamlessPayCore;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  [[SPAPIClient getSharedInstance] setSecretKey: nil
                                 publishableKey: @"pk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
                                    environment: SPEnvironmentSandbox];

  return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
  return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


@end
