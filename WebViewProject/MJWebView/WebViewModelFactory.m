//
//  WebViewModelFactory.m
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import "WebViewModelFactory.h"
#import "WKWebViewModel.h"
#import "UIWebViewModel.h"
#import <objc/runtime.h>

#define GREATER_THAN_IOS7X ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation WebViewModelFactory

+ (AbstractWebViewModel *)factoryWithType:(WebViewModelCreateType)type showProgressView:(BOOL)show viewController:(UIViewController *)viewController {
    AbstractWebViewModel *model = nil;
    if(objc_lookUpClass("WKWebView") == nil) {
        type = WebViewModelCreateTypeUIWebView;
    }
    
    
    
    switch (type) {
        case WebViewModelCreateTypeUIWebView: {
            model = [[UIWebViewModel alloc] initWithShowProgressView:show withViewController:viewController];
        }
            break;
        case WebViewModelCreateTypeWKWebView: {
            model = [[WKWebViewModel alloc] initWithShowProgressView:show withViewController:viewController];
        }
            break;
        default: {
            if (GREATER_THAN_IOS7X) {
                model = [[WKWebViewModel alloc] initWithShowProgressView:show withViewController:viewController];
            } else {
                model = [[UIWebViewModel alloc] initWithShowProgressView:show withViewController:viewController];
            }
        }
            break;
    }
    return model;
}

@end
