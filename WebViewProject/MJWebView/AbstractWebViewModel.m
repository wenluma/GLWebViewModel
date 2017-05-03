//
//  AbstractWebViewModel.m
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import "AbstractWebViewModel.h"

@class WKWebViewModel;
@class UIWebViewModel;

@implementation AbstractWebViewModel
- (instancetype)initWithShowProgressView:(BOOL)show withViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.showProgressView = show;
        self.weakVC = viewController;
    }
    return self;
}
#pragma mark - web feature
- (void)loadURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}

- (void)loadRequest:(NSURLRequest *)request {
}

- (BOOL)canGoBack {
    return NO;
}

- (void)goBack {
}

- (void)reload {
}

- (NSURL *)URL {
    return nil;
}
//MARK: webview help -
- (NSString *)excuteJSFunction:(NSString *)script {
    return nil;
}

- (id<WKNavigationDelegate, UIWebViewDelegate>)webViewDelegate {
    return nil;
}

#pragma mark - help
- (void)supportNavigationInteractivePopGestureWhenPanGesture:(UIScrollView *)scrollView {
    UINavigationController *nav = [self.weakVC isKindOfClass:[UINavigationController class]] ? (UINavigationController *)self.weakVC : self.weakVC.navigationController;
    if (nav) {
        [scrollView.panGestureRecognizer requireGestureRecognizerToFail:nav.interactivePopGestureRecognizer];
    }
}

+ (NSString *)webViewUserAgent {
    return nil;
}

@end
