//
//  WebInfoObject.m
//  Test
//
//  Created by miaogaoliang on 2017/1/18.
//  Copyright © 2017年 miaogaoliang. All rights reserved.
//

#import "WebInfoObject.h"

@implementation WebInfoObject

@end

@implementation NSString (JSTryCatch)
- (NSString *)addJSTryCatch {
    return [NSString stringWithFormat:@"try {%@} catch(err) {}", self];
}
@end
