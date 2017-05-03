//
//  AbstractWebViewModel.h
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WebInfoObject.h"
#import <WebKit/WebKit.h>

#define MJProgressTintColor [[UIColor alloc] initWithRed:0 green:0X97 / 255.0f blue:0Xe0 / 255.0f alpha:1]

@protocol MJWebViewFeatureDelegate <NSObject>

- (void)loadURL:(NSURL *)url;
- (void)loadRequest:(NSURLRequest *)request;
- (BOOL)canGoBack;
- (void)goBack;
- (void)reload;
- (NSURL *)URL;
- (NSString *)excuteJSFunction:(NSString *)script;

@end

@interface AbstractWebViewModel : NSObject <MJWebViewFeatureDelegate>

@property (nonatomic, strong) UIView *webView;// webView
@property (nonatomic, strong) UIView *progressView;//进度view
@property (nonatomic, assign) BOOL showProgressView;// default = yes
@property (nonatomic, weak) UIViewController *weakVC;
@property (nonatomic, weak) id<MJWebViewDelegate> webDelegate;//为web 请求及状态回调
@property (nonatomic, strong) UIColor *progressTintColor;// 默认为 nil， 修改进度条颜色值

- (instancetype)initWithShowProgressView:(BOOL)show withViewController:(UIViewController *)viewController;

- (id<WKNavigationDelegate, UIWebViewDelegate>)webViewDelegate;// 为 jssdk 使用
- (void)supportNavigationInteractivePopGestureWhenPanGesture:(UIScrollView *)scrollView;//支持侧边滑动

+ (NSString *)webViewUserAgent;

@end



