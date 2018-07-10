//
//  AppDelegate.m
//  CommonLogin
//
//  Created by xrs_fang on 2018/7/10.
//  Copyright © 2018年 xrs_fang. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WXApi registerApp:WXAppID];//注册微信
    //微博登录
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:WBAppKey];
    
    
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    NSString *str = [NSString stringWithFormat:@"%@",url];
    
    if ([str hasPrefix:WXAppID]) {//微信
        return [WXApi handleOpenURL:url delegate:self];
        
    }else if ([str hasPrefix:@"wb1713016460"]) {//微博
        return [WeiboSDK handleOpenURL:url delegate:self];
        
    }else if ([str hasPrefix:@"tencent"]){//qq
        return [TencentOAuth HandleOpenURL:url];
    }
    return NO;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatio
{
    NSString *str = [NSString stringWithFormat:@"%@",url];
    
    if ([str hasPrefix:WXAppID]) {
        return [WXApi handleOpenURL:url delegate:self];
        
    }else if ([str hasPrefix:@"wb1713016460"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
        
    }else if ([str hasPrefix:@"tencent"]){
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return NO;
}

- (void)onResp:(BaseResp *)resp {
    // 向微信请求授权后,得到响应结果
    if([resp isKindOfClass:[SendAuthResp class]]){
        SendAuthResp *response = (SendAuthResp *)resp;
        if(response.errCode == 0){//授权成功
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WXGetCode" object:@{@"code":response.code}];
            
        }else if (response.errCode == -2){//用户取消
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"授权失败，用户取消" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }else if (response.errCode == -4){//用户拒绝授权
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"授权失败，用户拒绝授权" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
}

//微博回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        NSString *userId = [(WBAuthorizeResponse*)response userID];
        NSString *accessToken = [(WBAuthorizeResponse*)response accessToken];
        
        if (userId == nil || [userId isEqual:[NSNull null]]) {
            return;
        }
        
        NSDictionary *dicInfo = @{@"userId":userId,@"accessToken":accessToken};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WBGetResponse" object:dicInfo];
    }
    
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if(response.statusCode == WeiboSDKResponseStatusCodeSuccess){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"分享成功"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"分享失败"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
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


@end
