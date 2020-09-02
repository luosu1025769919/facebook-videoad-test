//
//  EgAdMgr.m
//  EGKit
//
//  Created by jenkins_xiyou on 2020/8/4.
//  Copyright © 2020 萌果科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EgAdMgr.h"
#import "EGMacro.h"
#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@import FBAudienceNetwork;
@interface EgAdMgrController : EgAdMgr





@end

@implementation EgAdMgr


- (instancetype)init {
    self = [super init];
    

   _is_google_flag= false;
    _index=0;
 
    return self;
}

-(void) initAd{
    
   
      [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
  [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(getad_config)
                                                       name:kNetworkReachability
                                                     object:nil];
    
    
}

-(void) getad_config{
     NSMutableDictionary *signParams = [[NSMutableDictionary alloc] initWithCapacity:0];
        [signParams setDictionary: @{
                                        @"app_id":self.manager.appId ,
                                        @"phone_type":@"1"}];
    
        signParams[@"sign"] = [EGUtility RSASign:signParams];
        @weakify_self;
        [GET_HTTP_API post:[EGConfig get_ad_config]
                      body:signParams
                  complete:^(id JSONResponse, NSError *error) {
                      @strongify_self;
                      if (error) {
                             NSLog(@"数据error：----%@" ,error);
                          self.AdCallBack(2);
                      }
                      else {
                          NSLog(@"数据：----%@" ,JSONResponse);
                          NSNumber *code= JSONResponse[@"code"];
                          if ([code isEqualToNumber:@(1122)]) {
                              self.AdCallBack(1);
                          }else{
                              NSMutableArray *nowlist=JSONResponse[@"result"][@"ads"];
                                              NSSortDescriptor *lastDescriptor =
                                              [[NSSortDescriptor alloc] initWithKey:@"priority"
                                                                         ascending:YES
                                                                        ];
                                                   NSArray *array = [NSArray arrayWithObject: lastDescriptor];
                                                   _list= [nowlist sortedArrayUsingDescriptors:array];
                                               
                                                   
                                                   NSLog(@"----0:%d",[_list[0][@"priority"]intValue]);
                                                      NSLog(@"----1:%d",[_list[1][@"priority"]intValue]);
                                                    self.AdCallBack(0);
                          }
                          
               
                      }
                  }];
}



-(void) loadAd{
    if (_index>=_list.count-1) {
        _index=0;
    }
    if (_list!=NULL&&_list.count>0) {
        NSDictionary *ad=_list[_index] ;
        if ([ad[@"ad_type"] isEqualToString:@"facebook"]) {
           //facebook
            self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:ad[@"ad_id"]];
             self.rewardedVideoAd.delegate = self;
             [self.rewardedVideoAd loadAd];
            
            
        }else{
         
              self.rewardedAd = [[GADRewardedAd alloc]
                     initWithAdUnitID:ad[@"ad_id"]];
             GADRequest *request = [GADRequest request];
      [self.rewardedAd loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
        if (error) {
          // Handle ad failed to load case.
            NSLog(@"load ad error");
            _index++;
            [self loadAd];
              self.AdCallBack(4);
        } else {
               NSLog(@"load ad complete");
          // Ad successfully loaded.
            self.is_google_flag=true;
            //加载成功
               self.AdCallBack(3);
            
        }
      }];
            
        }
        
        
        
        
        
    }
    
}

-(void) showAd: (UIViewController*)controller{
    if (_is_google_flag) {
        if (self.rewardedAd.isReady) {
          [self.rewardedAd presentFromRootViewController:ROOT_VIEWCONTROLLER delegate:self];
        } else {
          NSLog(@"Ad wasn't ready");
        }

    }else{
        
        if (self.rewardedVideoAd && self.rewardedVideoAd.isAdValid) {
           UIViewController* appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.rewardedVideoAd showAdFromRootViewController:controller animated:NO];
         }
        
    }
    
}


/// Tells the delegate that the user earned a reward.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
  // TODO: Reward the user. 播放成功
  NSLog(@"rewardedAd:userDidEarnReward:");
       self.AdCallBack(5);
        [self loadAd];
}

/// Tells the delegate that the rewarded ad was presented.
- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    //广告现在已被展示
  NSLog(@"rewardedAdDidPresent:");
   
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
  NSLog(@"rewardedAd:didFailToPresentWithError");
    //未能展示
    _index++;
      [self loadAd];
    
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
  NSLog(@"rewardedAdDidDismiss:");
    // 用户关闭
      self.AdCallBack(7);
}








- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
  NSLog(@"Rewarded video ad failed to load");
    //加载失败
    _index++;
    [self loadAd];
  self.AdCallBack(4);
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Video ad is loaded and ready to be displayed");
    //加载成功
    self.AdCallBack(3);
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"Video ad clicked");
       //广告被点击
     self.AdCallBack(6);
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd;
{
  NSLog(@"rewardedVideoAdVideoComplete");
       //广告播放成功，发放奖励
     self.AdCallBack(5);
        [self loadAd];
}

-(void) rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd{
      NSLog(@"-----rewardedVideoAdWillClose---");
}
- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
  NSLog(@"rewardedVideoAdDidClose");
       //广告关闭
     self.AdCallBack(7);
}



@end
