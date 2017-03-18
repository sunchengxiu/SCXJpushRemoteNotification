//
//  AppDelegate.m
//  远程推送
//
//  Created by 孙承秀 on 16/12/27.
//  Copyright © 2016年 孙先森丶. All rights reserved.
//

#import "AppDelegate.h"

#define JGAPP_KEY @"f7d08b9d3eec8bb32a645518"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc]init];
        category.identifier = @"remoteNotification";
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc]init];
        action.identifier = @"jqk";
        action.title = @"jqk";
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.authenticationRequired = NO;
        action.destructive = YES;
        
        action.behavior = UIUserNotificationActionBehaviorTextInput;
        action.parameters = @{UIUserNotificationTextInputActionButtonTitleKey : @"放弃"};
        
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc]init];
        action1.identifier = @"shunzi";
        action1.title = @"顺子";
        action1.activationMode = UIUserNotificationActivationModeForeground;
        action1.authenticationRequired = NO;
        action1.destructive = NO;
        action1.behavior = UIUserNotificationActionBehaviorTextInput;
        action1.parameters = @{UIUserNotificationTextInputActionButtonTitleKey : @"压死"};
        [category setActions:@[action , action1] forContext:UIUserNotificationActionContextMinimal];
        
       
        [JPUSHService registerForRemoteNotificationTypes:type categories:[NSSet setWithObject:category]];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
   
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
  
    [JPUSHService setupWithOption:launchOptions appKey:JGAPP_KEY
                          channel:@"app store"
                 apsForProduction:0
            advertisingIdentifier:nil];
    //[self registerRemoteNotification];
    return YES;
}

#pragma mark - 注册远程通知
- (void)registerRemoteNotification{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
    
        UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

# pragma mark - 获取deviceToken
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"%@",deviceToken);

}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{

    NSLog(@"%@",error);

}
// 从后台进入前台和前台的时候会调用这个方法
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}
// 7.0之后,这个方法调用了，上面的方法就不会被调用
// 从后台进入前台的时候会调用
// 这个方法，完全退出的时候也会调用
// 只要接受到了通知，无论是在什么状态都会调用这个方法.
// 必须勾选后台模式
// 告诉系统是否有新的内容更新（执行完成代码块）
// 设置发送通知的格式("content-available" : "")
// 调用完成代码块之后，缩略图会更新
/*
 {"aps":{"alert":"This is some fancy message.","badge":1 , "content-available" : "xx"}}
 */
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{

    self.window.rootViewController.view.backgroundColor = [UIColor orangeColor];
    // 加入这个方法，在缩略图的时候会直接显示效果,前提推送格式必须有"content-available"
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(9_0) {
    if ([identifier isEqualToString:@"comment-reply"]) {
        NSString *response = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        //对输入的文字作处理
    }
    completionHandler();
}
@end
