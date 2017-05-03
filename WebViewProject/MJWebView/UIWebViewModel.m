//
//  UIWebViewModel.m
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import "UIWebViewModel.h"
#import "NJKWebViewProgress.h"

@interface UIWebViewModel ()<UIWebViewDelegate>
@property (nonatomic, strong) NJKWebViewProgress *webProgress;
@end

@implementation UIWebViewModel
- (instancetype)initWithShowProgressView:(BOOL)show withViewController:(UIViewController *)viewController {
    self = [super initWithShowProgressView:show withViewController:viewController];
    if (self) {
        [self.webView addSubview:self.progressView];
        self.progressView.frame = CGRectMake(0, 0, CGRectGetMaxX(self.webView.frame), 2);
        self.webProgress = [[NJKWebViewProgress alloc] init];
        [[self myWebView] setDelegate:self.webProgress];
        __typeof(self) __weak weakSelf = self;
        self.webProgress.progressBlock = ^(float progress) {
            [[weakSelf myProgressView] setProgress:progress animated:YES];
        };
    }
    return self;
}

#pragma mark -
- (id<WKNavigationDelegate, UIWebViewDelegate>)webViewDelegate {
    return (id<WKNavigationDelegate, UIWebViewDelegate>)self.webProgress.webViewProxyDelegate;
}
#pragma mark - web view , progress view init
- (UIWebView *)myWebView {
    return (UIWebView *)self.webView;
}

- (UIProgressView *)myProgressView {
    return (UIProgressView *)self.progressView;
}
- (UIView *)webView {
    if ([super webView] == nil) {
        UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        webView.delegate = self;
        webView.backgroundColor = [UIColor clearColor];
        webView.allowsInlineMediaPlayback = YES;
        webView.scalesPageToFit = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self supportNavigationInteractivePopGestureWhenPanGesture:webView.scrollView];
        [super setWebView:webView];
    }
    return [super webView];
}

- (UIView *)progressView {
    if ([super progressView] == nil) {
       UIProgressView* progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [super setProgressView:progressView];
    }
    return [super progressView];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    if (progressTintColor == nil) {
        progressTintColor = MJProgressTintColor;
    }
    [super setProgressTintColor:progressTintColor];
    [[self myProgressView] setProgressTintColor:progressTintColor];
}

- (void)showProgressBar {
    if ([self showProgressView]) {
        self.progressView.hidden = NO;
    }
}

- (void)hideProgressBar {
    self.progressView.hidden = YES;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.webDelegate respondsToSelector:@selector(shouldAllowRequestWithInfo:)]) {
        WebInfoObject *info = [[WebInfoObject alloc] init];
        info.request = request;
        info.type = navigationType;
        MJRequestPolicy policy = [self.webDelegate shouldAllowRequestWithInfo:info];
        if (policy != MJRequestPolicyIgnore) {
            return policy;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.webView setHidden:!self.showProgressView];
    if (self.showProgressView) {
        [self showProgressBar];
    }
    if ([self.webDelegate respondsToSelector:@selector(webRequestStartWithInfo:)]) {
        [self.webDelegate webRequestStartWithInfo:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideProgressBar];

    WebInfoObject *info = [[WebInfoObject alloc] init];
    info.canGoBack = webView.canGoBack;
    info.title = [self excuteJSFunction:@"document.title".addJSTryCatch];
    if ([self.webDelegate respondsToSelector:@selector(webRequestFinishLoadWithInfo:)]) {
        [self.webDelegate webRequestFinishLoadWithInfo:info];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideProgressBar];

    WebInfoObject *info = [[WebInfoObject alloc] init];
    info.error = error;
    if ([self.webDelegate respondsToSelector:@selector(webRequestFailLoadWithInfo:)]) {
        [self.webDelegate webRequestFailLoadWithInfo:info];
    }
}

#pragma mark - MJWebViewFeatureDelegate
- (void)loadRequest:(NSURLRequest *)request {
    if ([self myWebView]) {
        [[self myWebView] loadRequest:request];
    }
}

- (BOOL)canGoBack {
    if ([self myWebView]) {
        return [[self myWebView] canGoBack];
    }
    return NO;
}

- (void)goBack {
    if ([self myWebView]) {
        [[self myWebView] goBack];
    }
}

- (void)reload {
    if ([self myWebView]) {
        [[self myWebView] reload];
    }
}

- (NSURL *)URL {
    if ([self myWebView]) {
        return [[[self myWebView] request] URL];
    }
    return nil;
}

- (NSString *)excuteJSFunction:(NSString *)jsfunc {
    if (self.myWebView) {
        return [self.myWebView stringByEvaluatingJavaScriptFromString:jsfunc];
    }
    return nil;
}

- (void)removeCookiesForKeys:(NSArray *)names {
    NSArray *ary = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSMutableArray *__block deleteCookieAry = [[NSMutableArray alloc] initWithCapacity:2];
    [ary enumerateObjectsUsingBlock:^(NSHTTPCookie *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([names containsObject:obj.name]) {
            [deleteCookieAry addObject:obj];
        }
    }];
    NSInteger count = deleteCookieAry.count;
    for (NSInteger i = 0; i < count; i++) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:deleteCookieAry[i]];
    }
    [deleteCookieAry removeAllObjects];
}

#pragma mark - 
+ (NSString *)webViewUserAgent {
    static NSString *userAgentInfo = nil;
    if (!userAgentInfo) {
        UIWebViewModel *model = [[UIWebViewModel alloc] initWithShowProgressView:NO withViewController:nil];
        userAgentInfo = [model excuteJSFunction:@"navigator.userAgent"];
    }
    return userAgentInfo;
}
@end
