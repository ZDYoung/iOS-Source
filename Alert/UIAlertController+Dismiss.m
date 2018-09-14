//
//  UIAlertController+Dismiss.m
//  alert
//
//  Created by 张冬阳 on 2018/9/14.
//  Copyright © 2018年 张冬阳. All rights reserved.
//

#import "UIAlertController+Dismiss.h"
#import <objc/runtime.h>

@implementation UIAlertController (Dismiss)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        //在iOS 11.0以上UIAlertController的dimiss的私有方法是_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:dismissCompletion:
        //iOS 11.0以下是_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:
        SEL originalSelectorWitCompletion = NSSelectorFromString(@"_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:dismissCompletion:");
        SEL originalSelector = NSSelectorFromString(@"_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:");
        
        SEL swizzledSelector = @selector(zdy_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:);
        
        SEL swizzledSelectorWithCompletion = @selector(zdy_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:dismissCompletion:);
        
        Method originalMethodWithCompletion = class_getInstanceMethod(class, originalSelectorWitCompletion);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method swizzledMethodWithCompletion = class_getInstanceMethod(class, swizzledSelectorWithCompletion);
        if (originalMethodWithCompletion) {
            method_exchangeImplementations(originalMethodWithCompletion, swizzledMethodWithCompletion);
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)zdy_dismissAnimated:(BOOL)animation triggeringAction:(UIAlertAction *)action triggeredByPopoverDimmingView:(id)view dismissCompletion:(id)handler
{
    if (action.style == UIAlertActionStyleCancel) {
        [self zdy_dismissAnimated:animation triggeringAction:action triggeredByPopoverDimmingView:view dismissCompletion:handler];
    } else {
        if (self.validateBlock && self.textFields.count) {
            self.isDismiss = self.validateBlock(self.textFields.firstObject.text);
            if (self.isDismiss) {
                [self zdy_dismissAnimated:animation triggeringAction:action triggeredByPopoverDimmingView:view dismissCompletion:handler];
            }
        } else {
            [self zdy_dismissAnimated:animation triggeringAction:action triggeredByPopoverDimmingView:view dismissCompletion:handler];
        }
    }
}

- (void)zdy_dismissAnimated:(BOOL)animation triggeringAction:(UIAlertAction *)action triggeredByPopoverDimmingView:(id)view
{
    if (action.style == UIAlertActionStyleCancel) {
        [self zdy_dismissAnimated:animation triggeringAction:action triggeredByPopoverDimmingView:view];
    } else {
        if (self.validateBlock && self.textFields.count) {
            self.isDismiss = self.validateBlock(self.textFields.firstObject.text);
            if (self.isDismiss) {
                [self zdy_dismissAnimated:animation triggeringAction:action triggeredByPopoverDimmingView:view];
            }
        } else {
            [self zdy_dismissAnimated:animation triggeringAction:action triggeredByPopoverDimmingView:view];
        }
    }
}

- (void)setIsDismiss:(BOOL)isDismiss
{
    objc_setAssociatedObject(self, @selector(isDismiss), @(isDismiss), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isDismiss
{
    return [(NSNumber *)objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setValidateBlock:(AlertControllerTextFieldValidateBlock)validateBlock
{
    objc_setAssociatedObject(self, @selector(validateBlock), validateBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (AlertControllerTextFieldValidateBlock)validateBlock
{
    return objc_getAssociatedObject(self, @selector(validateBlock));
}

- (void)setWindow:(UIWindow *)window
{
    objc_setAssociatedObject(self, @selector(window), window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)window
{
    return objc_getAssociatedObject(self, @selector(window));
}

- (void)addActionWithStyle:(UIAlertActionStyle)style title:(NSString *)title
                     block:(AlertControllerActionBlock)block {
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:style
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            BOOL isDismiss = self.isDismiss ? : YES;
                                                            if (isDismiss && self.window) {
                                                                self.window.rootViewController = nil;
                                                                self.window.hidden = YES;
                                                            }
                                                            if (block) {
                                                                block();
                                                            }
                                                        }];
    
    [self addAction:alertAction];
}

- (void)showInController:(UIViewController *)destinationController {
    if (destinationController) {
        UIViewController *presentedVC = destinationController.presentedViewController;
        if (presentedVC) {
            [presentedVC presentViewController:self animated:YES completion:NULL];
        } else {
            [destinationController presentViewController:self animated:YES completion:NULL];
        }
    }
}

- (void)showInWindow
{
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.hidden = NO;
        UIViewController *vc = [[UIViewController alloc] init];
        self.window.rootViewController = vc;
    }
    UIWindow *orignalWindow = [[UIApplication sharedApplication] keyWindow];
    self.window.windowLevel = orignalWindow.windowLevel + 1.0f;
    [self.window.rootViewController presentViewController:self animated:YES completion:nil];
}
@end
