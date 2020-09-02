//
//  EgAdMgr.h
//  EGKitDemo
//
//  Created by jenkins_xiyou on 2020/8/4.
//  Copyright © 2020 萌果科技. All rights reserved.
//

#ifndef EgAdMgr_h
#define EgAdMgr_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class EGManager;
@import GoogleMobileAds;
@import FBAudienceNetwork;

#endif /* EgAdMgr_h */
@interface  EgAdMgr :UIViewController<GADRewardedAdDelegate,FBRewardedVideoAdDelegate>

@property (nonatomic, weak) EGManager *manager;
@property (nonatomic, copy) void(^AdCallBack)(int code);
@property  int index;
@property  Boolean is_google_flag ;
@property(nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, copy) NSArray *list;
-(void) initAd ;
-(void)  loadAd;
-(void)  showAd:(UIViewController*)controller;
@end
