//
//  WebViewModelFactory.h
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractWebViewModel.h"

@class UIViewController;
typedef NS_ENUM(NSInteger, WebViewModelCreateType) {
    WebViewModelCreateTypeAuto,
    WebViewModelCreateTypeUIWebView,
    WebViewModelCreateTypeWKWebView,
};

@interface WebViewModelFactory : NSObject
+ (AbstractWebViewModel *)factoryWithType:(WebViewModelCreateType)type showProgressView:(BOOL)show viewController:(UIViewController *)viewController;
@end
