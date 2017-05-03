//
//  WebInfoObject.h
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 web 信息传递的数据封装。
 */
@interface WebInfoObject : NSObject
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL canGoBack;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSError *error;
@end

typedef NS_ENUM(NSInteger, MJRequestPolicy) {
    MJRequestPolicyIgnore = -1,
    MJRequestPolicyDeny = 0,
    MJRequestPolicyAllow = 1,
};

@protocol MJWebViewDelegate <NSObject>

- (MJRequestPolicy)shouldAllowRequestWithInfo:(WebInfoObject *)info;
- (void)webRequestStartWithInfo:(WebInfoObject *)info;
- (void)webRequestFinishLoadWithInfo:(WebInfoObject *)info;
- (void)webRequestFailLoadWithInfo:(WebInfoObject *)info;

@end

@interface NSString (JSTryCatch)
- (NSString *)addJSTryCatch;
@end
