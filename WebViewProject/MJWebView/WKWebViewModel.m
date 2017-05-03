//
//  WKWebViewModel.m
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import "WKWebViewModel.h"

@interface WKWebViewModel ()<WKUIDelegate, WKNavigationDelegate>
@end

@implementation WKWebViewModel

- (instancetype)initWithShowProgressView:(BOOL)show withViewController:(UIViewController *)viewController {
    self = [super initWithShowProgressView:show withViewController:viewController];
    if (self) {
        [self.webView addSubview:self.progressView];
        self.progressView.frame = CGRectMake(0, 0, CGRectGetMaxX(self.webView.frame), 2);
    }
    return self;
}

- (void)dealloc {
    if ([self myWebView]) {
        [[self myWebView] removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
}
#pragma mark -
- (id<WKNavigationDelegate, UIWebViewDelegate>)webViewDelegate {
    return (id<WKNavigationDelegate, UIWebViewDelegate>)self;
}
#pragma mark - web view , progress view init
- (WKWebView *)myWebView {
     return (WKWebView *)self.webView;
}

- (UIProgressView *)myProgressView {
    return (UIProgressView *)self.progressView;
}

- (UIView *)webView {
    if ([super webView] == nil) {
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *scaleToFitScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *userContent = [[WKUserContentController alloc] init];
        [userContent addUserScript:scaleToFitScript];
        
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        wkWebView.configuration.allowsInlineMediaPlayback = YES;//允许网页里，播放多媒体
        wkWebView.configuration.userContentController = userContent;
        
        wkWebView.navigationDelegate = self;
        wkWebView.UIDelegate = self;
       
        wkWebView.backgroundColor = [UIColor clearColor];
        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
        
        [self supportNavigationInteractivePopGestureWhenPanGesture:wkWebView.scrollView];
        [super setWebView:wkWebView];
    }
    return [super webView];
}

- (UIView *)progressView {
    if ([super progressView] == nil) {
        UIProgressView* progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.progressTintColor = MJProgressTintColor;
        progressView.trackTintColor = [UIColor clearColor];
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
#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.myWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        [self.myProgressView setProgress:newprogress animated:YES];
        if (newprogress == 1.0) {
            [self myProgressView].hidden = YES;
        }
    }
}

#pragma mark - WKNavigationDelegate
//allow or cancel request -判断，是否允许发起请求
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self.webDelegate respondsToSelector:@selector(shouldAllowRequestWithInfo:)]) {
        WebInfoObject *info = [[WebInfoObject alloc] init];
        info.request = navigationAction.request;
        info.type = navigationAction.navigationType;
        MJRequestPolicy policy = [self.webDelegate shouldAllowRequestWithInfo:info];
        if (policy != MJRequestPolicyIgnore) {
            decisionHandler((WKNavigationActionPolicy)policy);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = !self.showProgressView;
    if ([self.webDelegate respondsToSelector:@selector(webRequestStartWithInfo:)]) {
        [self.webDelegate webRequestStartWithInfo:nil];
    }
}

// 内容返回时
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

//成功
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = YES;
    
    WebInfoObject *info = [[WebInfoObject alloc] init];
    info.canGoBack = webView.canGoBack;
    info.title = [self excuteJSFunction:@"document.title".addJSTryCatch];
    if ([self.webDelegate respondsToSelector:@selector(webRequestFinishLoadWithInfo:)]) {
        [self.webDelegate webRequestFinishLoadWithInfo:info];
    }
}

//失败
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;

    WebInfoObject *info = [[WebInfoObject alloc] init];
    info.error = error;
    if ([self.webDelegate respondsToSelector:@selector(webRequestFailLoadWithInfo:)]) {
        [self.webDelegate webRequestFailLoadWithInfo:info];
    }
}
#pragma mark - web UI delegate
/*  警告 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // web 调用 js，并等待结果
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    
    [alertController addAction:cancelAction];
    [self.weakVC presentViewController:alertController animated:YES completion:nil];
}

///** 确认框 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(0);
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(1);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self.weakVC presentViewController:alertController animated:YES completion:nil];
}
/**  输入框 */
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
//    [[[UIAlertView alloc] initWithTitle:@"输入框" message:prompt delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil] show];
//    completionHandler(@"你是谁！");
//}
// 创建新的webView
// 可以指定配置对象、导航动作对象、window特性。如果没用实现这个方法，不会加载链接，如果返回的是原webview会崩溃。
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
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
        return [[self myWebView] URL];
    }
    return nil;
}
#pragma mark - web method delegate
- (NSString *)excuteJSFunction:(NSString *)script async:(BOOL)async {
    if (self.myWebView) {
        __block NSString *resultString = nil;
        __block BOOL finished = NO;
        
        [self.myWebView evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
            if (error == nil && result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
            finished = YES;
        }];
        //容错保护，超过1s 还没有正确的数据，返回 nil， 防止卡死。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            finished = YES;
        });
        if (async == NO) {
            while (!finished) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        
        return resultString;
    }
    return nil;
}

- (NSString *)excuteJSFunction:(NSString *)script {
    return [self excuteJSFunction:script async:NO];
}

+ (NSString *)webViewUserAgent {
    static NSString *userAgentInfo = nil;
    if (!userAgentInfo) {
        WKWebViewModel *model = [[WKWebViewModel alloc] initWithShowProgressView:NO withViewController:nil];
        userAgentInfo = [model excuteJSFunction:@"navigator.userAgent"];
    }
    return userAgentInfo;
}
@end
