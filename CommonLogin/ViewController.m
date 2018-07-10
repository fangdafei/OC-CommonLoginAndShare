//
//  ViewController.m
//  CommonLogin
//
//  Created by xrs_fang on 2018/7/10.
//  Copyright © 2018年 xrs_fang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<TencentSessionDelegate,WeiboSDKDelegate,TencentLoginDelegate>

@property (nonatomic, strong) TencentOAuth *tencentLogin;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //注册微信通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCode:) name:@"WXGetCode" object:nil];
    //注册微博通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wbGetResponse:) name:@"WBGetResponse" object:nil];
    
}

#pragma mark- QQ登录
- (IBAction)QQLogin:(id)sender {
    
    self.tencentLogin = [[TencentOAuth alloc] initWithAppId:TXAppID andDelegate:self];
    
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            nil];
    
    [self.tencentLogin authorize:permissions inSafari:NO];
}


#pragma mark- 微信登录
- (IBAction)weixinLogin:(id)sender {
    
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo";
    req.state = WXState;
    [WXApi sendReq:req];
    
}

#pragma mark- 微博登录
- (IBAction)weiboLogin:(id)sender {
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = WBRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

#pragma mark- QQ分享
- (IBAction)shareQQ:(id)sender {
    
    if (![TencentOAuth iphoneQQInstalled]) {
        //[self presentSheet:@"请您先下载QQ" duration:2.0]; //没下载QQ弹窗提示
    }else{
        self.tencentLogin = [[TencentOAuth alloc] initWithAppId:TXAppID andDelegate:self];
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:@"www.baidu.com"]
                                    title:[NSString stringWithFormat:@"%@ 正在邀请你一起玩",@"小明"]
                                    description:@"邀请您一起视频一起high！"
                                    previewImageURL:nil];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
    }
}

#pragma mark- 微信分享
- (IBAction)shareWeixin:(id)sender {
    
    if (![WXApi isWXAppInstalled]) {
        //[self presentSheet:@"请您先下载微信" duration:2.0];
    }else {
        SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
        sendReq.bText = NO;
        sendReq.scene = 1;// 0：分享到好友列表 1：分享到朋友圈  2：收藏
        
        //创建分享内容
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [NSString stringWithFormat:@"%@ 正在邀请你一起玩",@"小明"];
        message.description = @"邀请您一起视频一起high！";
        [message setThumbImage:[UIImage imageNamed:@"AppIcon"]];//带图片
        
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = [NSString stringWithFormat:@"%@", @"www.baidu.com"];//分享的连接
        message.mediaObject = webObj;
        sendReq.message = message;
        [WXApi sendReq:sendReq];
    }
    
}

#pragma mark- 微博分享
- (IBAction)shareWeibo:(id)sender {
    
    if (![WeiboSDK isWeiboAppInstalled]) {
        //[self presentSheet:@"请您先下载微博" duration:2.0];
    }else {
        
        WBMessageObject *wbmsg = [WBMessageObject message];
        wbmsg.text = [NSString stringWithFormat:@"%@ 邀请您一起视频一起high！%@",@"小明",@"www.baidu.com"];
        WBImageObject *wbImg = [[WBImageObject alloc] init];
        UIImageView *imagev = [[UIImageView alloc] init];
        //imagev.image = kIMAGE(@"AppIcon");//图片
        NSData *imageData = UIImagePNGRepresentation(imagev.image);
        
        wbImg.imageData = imageData;
        wbmsg.imageObject = wbImg;
        
        WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
        authRequest.redirectURI = WBRedirectURI;
        authRequest.scope = @"all";
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:wbmsg authInfo:authRequest access_token:nil];
        
        [WeiboSDK sendRequest:request];
        
    }
    
    
}




- (void)wbGetResponse:(NSNotification *)notification
{
    NSDictionary *dicInfo = [notification object];
    NSString *accessToken = [dicInfo objectForKey:@"accessToken"];
    NSString *userId = [dicInfo objectForKey:@"userId"];
    
    
    if (accessToken.length) {
        [self thirdLoginRequestWithOpenID:userId withAccess_token:accessToken andSourceType:@"4"];
        [self getWeiboUserInfoWithAccessToken:accessToken uid:userId];
    }
}

- (void)getWeiboUserInfoWithAccessToken:(NSString *)accessToken uid:(NSString *)uid
{
    NSString *geturl =[NSString stringWithFormat:
                       @"https://api.weibo.com/2/users/show.json?access_token=%@&uid=%@",accessToken,uid];
    
    NSURL *url=[NSURL URLWithString:geturl];
    NSURLRequest *request=[NSURLRequest requestWithURL:url
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:3];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data) {
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        NSString *wbavatar_hd = [dict objectForKey:@"avatar_hd"];
        NSString *wbname = [dict objectForKey:@"name"];
        NSString *wbgender = [[dict objectForKey:@"gender"] isEqualToString:@"m"] ? @"1" : @"0";//1男0女
        
        NSDictionary *weiboDic = @{@"avatar_hd":wbavatar_hd,@"name":wbname,@"gender":wbgender};
        
        NSUserDefaults *weiboInfo = [NSUserDefaults standardUserDefaults];
        [weiboInfo setValue:weiboDic forKey:@"weiboInfo"];
        
    }else{
//        弹窗
//        [self presentSheet:@"获取用户信息失败" duration:2.0];
    }
}


- (void)getCode:(NSNotification *)notification
{
    NSString *wxCode = notification.object[@"code"];
    NSString *access_token = @"";
    NSString *openid = @"";
    if(wxCode.length){//获取access_token和openid
        
        NSString *token = [self WXgetAccess_tokenWithCode:wxCode];
        access_token =  token;
        NSDictionary *userInfoDict = [self WXgetUserinfoWithToken:token];
        
        openid = [userInfoDict valueForKey:@"openid"];
    }
    
    if(openid.length){
        
        [self thirdLoginRequestWithOpenID:openid withAccess_token:access_token andSourceType:@"2"];
    }
}


-(NSDictionary *)WXgetUserinfoWithToken:(NSString *)token{//获取用户信息
    if(token.length){
        NSString * getTockenUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,WXAppID];
        
        NSURL *url=[NSURL URLWithString:getTockenUrl];
        NSURLRequest *request=[NSURLRequest requestWithURL:url
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:3];
        
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (data) {
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            NSUserDefaults *weixinInfo = [NSUserDefaults standardUserDefaults];
            [weixinInfo setValue:dict forKey:@"weixinInfo"];
            
            return dict;
        }else{
//            弹窗
//            [self presentSheet:@"获取用户信息失败" duration:2.0];
        }
    }
    return nil;
}



-(NSString *)WXgetAccess_tokenWithCode:(NSString *)code{//获取access_token和openid
    if(code.length){
        NSString * getTockenUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAppID,WXAppSecret,code];
        
        NSURL *url=[NSURL URLWithString:getTockenUrl];
        NSURLRequest *request=[NSURLRequest requestWithURL:url
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:3];
        
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

//        存储消息
//        [Config currentConfig].weixin_access_token = [dict objectForKey:@"access_token"];
//        [Config currentConfig].weixin_openid = [dict objectForKey:@"openid"];
//        [Config currentConfig].weixin_unionid = [dict objectForKey:@"unionid"];
        
        return [dict valueForKey:@"access_token"];
    }
    return nil;
}


#pragma mark - 请求数据进行跳转
-(void)thirdLoginRequestWithOpenID:(NSString *)openid withAccess_token:(NSString *)access_token andSourceType:(NSString *)sourceType{
    ///////一些操作
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if ([sourceType isEqualToString:@"2"]) {//微信
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"auth_type":sourceType,@"weixin_access_token":access_token,@"weixin_openid":openid}];
    }else if ([sourceType isEqualToString:@"3"]){//qq
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"auth_type":sourceType,@"qq_access_token":access_token,@"qq_openid":openid}];
    }else if ([sourceType isEqualToString:@"4"]){//微博
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"auth_type":sourceType,@"weibo_access_token":access_token,@"weibo_openid":openid}];
        
    }
    ///////一些操作

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
