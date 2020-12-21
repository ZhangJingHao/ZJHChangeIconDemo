//
//  UIViewController+CustomPresent.m
//  ZJHChangeIconDemo
//
//  Created by ZhangJingHao48 on 2020/12/21.
//

#import "UIViewController+CustomPresent.h"
#import <objc/runtime.h>

@implementation UIViewController (CustomPresent)

+ (void)load {
    // 暂时注释掉，有需要可以打开
    return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(zjh_presentViewController:animated:completion:));
        method_exchangeImplementations(presentM, presentSwizzlingM);
    });
}

- (void)zjh_presentViewController:(UIViewController *)viewControllerToPresent
                         animated:(BOOL)flag
                       completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertController =
        (UIAlertController *)viewControllerToPresent;
        // 判断标题title、内容message是否为空
        if (alertController.title == nil && alertController.message == nil) {
            id conVC = [alertController valueForKey:@"_contentViewController"];
            if (conVC) {
                /* 判断_contentViewController的值是否为
                   _UIAlternateApplicationIconsAlertContentViewController */
                NSString *clsStr = NSStringFromClass([conVC class]);
                NSString *temStr = @"_UIAlternateApplicationIconsAlertContentViewController";
                if ([clsStr isEqualToString:temStr]) {
                    if (completion) {
                        completion();
                    }
                    NSLog(@"已切换");
                    return;
                }
            }
        } else {
            [self zjh_presentViewController:viewControllerToPresent
                                   animated:flag
                                 completion:completion];
            return;
        }
    }
    
    [self zjh_presentViewController:viewControllerToPresent
                           animated:flag
                         completion:completion];
}

@end
